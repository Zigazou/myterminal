module ram #(
	parameter CLK_FREQUENCY_HZ = 132_000_000,
	parameter CAS_LATENCY      = 3,

	parameter tRC_NS  = 63, // Row cycle time (bank=)
	parameter tRCD_NS = 21, // RAS to CAS delay (bank=)
	parameter tRP_NS  = 21, // Precharge to refresh/row activate delay (banks≠)
	parameter tRRD_NS = 14, // Row activate to row activate delay (banks≠)
	parameter tRAS_NS = 42, // Row activate to precharge time (bank=)
	parameter tWR_NS  = 2   // Write recovery time
) (
	input wire clk,
	input wire rst_n,

	// Read signals
	input wire rd_request,
	input wire [22:0] rd_address,
	output reg rd_available,
	output reg [31:0] rd_data,
	input wire [8:0] rd_burst_length,

	// Write signals
	input wire wr_request,
	output reg wr_done,
	input wire [3:0] wr_mask,
	input wire [22:0] wr_address,
	input wire [31:0] wr_data,
	input wire [8:0] wr_burst_length
);

// =============================================================================
// Useful constants
// =============================================================================
localparam
	LOW          = 0,
	HIGH         = 1,

	FALSE        = LOW,
	TRUE         = HIGH,

	FALSE_n      = HIGH,
	TRUE_n       = LOW,

	CLK_CYCLE_NS = 1_000_000_000 / CLK_FREQUENCY_HZ;

// =============================================================================
// EM638325 SDRAM specific timings
// =============================================================================
localparam
	DELAY_200_US_CYCLE = 200_000 / CLK_CYCLE_NS,
	BURST_LENGTH       = 1,

	REFRESH_OPERATIONS = 4_096,
	REFRESH_WINDOW_NS  = 64_000_000,
	REFRESH_CYCLE      = (REFRESH_WINDOW_NS / REFRESH_OPERATIONS)
					   / CLK_CYCLE_NS,

	tRC  = 1 + tRC_NS  / CLK_CYCLE_NS,
	tRCD = 1 + tRCD_NS / CLK_CYCLE_NS,
	tRP  = 1 + tRP_NS  / CLK_CYCLE_NS,
	tRRD = 1 + tRRD_NS / CLK_CYCLE_NS,
	tRAS = 1 + tRAS_NS / CLK_CYCLE_NS,
	tWR  = 1 + tWR_NS  / CLK_CYCLE_NS,
	tCK  = 7  / CLK_CYCLE_NS,
	tMRD = 1 + 2 * tCK,

	// Max counter value based on the setup duration.
	COUNTER_WIDTH = $clog2(
		DELAY_200_US_CYCLE + 1 + tRP + 8 * (tRC + tRP) + tMRD + 64
	),
	
	COUNTER_REFRESH_WIDTH = 1 + $clog2 (REFRESH_CYCLE);

// =============================================================================
// EG4S20 embedded SDRAM interface
// =============================================================================
reg cke;
reg cs_n;
reg ras_n;
reg cas_n;
reg we_n;
reg [10:0] addr;
reg [1:0] ba;
reg [3:0] dqm;

wire [31:0] dq;
reg [31:0] dq_r;
reg dq_wr;
assign dq = dq_wr ? dq_r : 32'hZZZZ_ZZZZ;

EG_PHY_SDRAM_2M_32 sdram (
	.clk (clk),
	.ras_n (ras_n),
	.cas_n (cas_n),
	.we_n (we_n),
	.addr (addr),
	.ba (ba),
	.dq (dq),
	.cs_n (cs_n),
	.dm0 (dqm[0]),
	.dm1 (dqm[1]),
	.dm2 (dqm[2]),
	.dm3 (dqm[3]),
	.cke (cke)
);

// =============================================================================
// Address structure
// =============================================================================
// 2 2 2 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
// 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
// --- --------------------- --------------- ---
// BNK          ROW               COLUMN     XXX
function [1:0] get_bank;
	input wire [22:0] address;
	get_bank = address[22:21];
endfunction

function [7:0] get_column;
	input wire [22:0] address;
	get_column = address[9:2];
endfunction

function [10:0] get_row;
	input wire [22:0] address;
	get_row = address[20:10];
endfunction

// =============================================================================
// SDRAM commands
// =============================================================================
localparam
	BIT_AUTO_PRECHARGE           = 10,
	WITH_AUTO_PRECHARGE          = HIGH,
	WITHOUT_AUTO_PRECHARGE       = LOW,

	//                                cke
	//                                | cs_n
	//                                | | ras_n
	//                                | | | cas_n
	//                                | | | | we_n 
	//                                | | | | |    
	COMMAND_BANK_ACTIVATE        = 5'b1_0_0_1_1,
	COMMAND_PRECHARGE            = 5'b1_0_0_1_0,
	COMMAND_WRITE                = 5'b1_0_1_0_0,
	COMMAND_READ                 = 5'b1_0_1_0_1,
	COMMAND_BURST_STOP           = 5'b1_0_1_1_0,
	COMMAND_NOP                  = 5'b1_0_1_1_1,
	COMMAND_INIT                 = 5'b0_0_1_1_1,
	COMMAND_AUTO_REFRESH         = 5'b1_0_0_0_1,
	COMMAND_MODE_REGISTER_SET    = 5'b1_0_0_0_0;

task command_bank_activate;
	input wire [1:0] bank;
	input wire [10:0] row_address;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_BANK_ACTIVATE;
		addr <= row_address;
		ba <= bank;
	end
endtask

task command_bank_precharge;
	input wire [1:0] bank;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_PRECHARGE;
		addr[BIT_AUTO_PRECHARGE] <= LOW;
		ba <= bank;
	end
endtask

task command_precharge_all;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_PRECHARGE;
		addr[BIT_AUTO_PRECHARGE] <= HIGH;
	end
endtask

task command_read;
	input wire [1:0] page;
	input wire [7:0] col_address;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_READ;
		dqm <= 4'b0000;
		ba <= page;
		addr[9:0] <= { 2'b00, col_address };
		addr[BIT_AUTO_PRECHARGE] <= WITHOUT_AUTO_PRECHARGE;
	end
endtask

task command_write;
	input wire [1:0] page;
	input wire [7:0] col_address;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_WRITE;
		dqm <= ~wr_mask;
		ba <= page;
		addr[9:0] <= { 2'b00, col_address };
		addr[BIT_AUTO_PRECHARGE] <= WITHOUT_AUTO_PRECHARGE;
	end
endtask

task command_burst_stop;
	{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_BURST_STOP;
endtask

task command_nop;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_NOP;
		dq_wr <= FALSE;
	end
endtask

task set_dq;
	input [31:0] data;
	begin
		dq_wr <= TRUE;
		dq_r <= data;
	end
endtask

task command_init;
	{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_INIT;
endtask

task command_auto_refresh;
	{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_AUTO_REFRESH;
endtask

// Constants used for SDRAM configuration ======================================
localparam
	MR_BURST_LENGTH_1                = 3'b000,
	MR_BURST_LENGTH_2                = 3'b001,
	MR_BURST_LENGTH_4                = 3'b010,
	MR_BURST_LENGTH_8                = 3'b011,
	MR_BURST_LENGTH_FULL_PAGE        = 3'b111,

	MR_BURST_TYPE_SEQUENTIAL         = 1'b0,
	MR_BURST_TYPE_INTERLEAVE         = 1'b1,

	MR_CAS_LATENCY_2                 = 3'b010,
	MR_CAS_LATENCY_3                 = 3'b011,

	MR_TEST_MODE_NORMAL              = 2'b00,
	MR_TEST_MODE_VENDOR_1            = 2'b10,
	MR_TEST_MODE_VENDOR_2            = 2'b01,

	MR_WRITE_BURST_LENGTH_BURST      = 1'b0,
	MR_WRITE_BURST_LENGTH_SINGLE_BIT = 1'b1,
	
	MR_RESERVED_FOR_FUTURE_USE       = 1'b0;

task command_mode_register_set;
	begin
		{ cke, cs_n, ras_n, cas_n, we_n } <= COMMAND_MODE_REGISTER_SET;
		ba <= { MR_RESERVED_FOR_FUTURE_USE, MR_RESERVED_FOR_FUTURE_USE };
		addr <= {
			MR_RESERVED_FOR_FUTURE_USE,
			MR_WRITE_BURST_LENGTH_BURST,
			MR_TEST_MODE_NORMAL,
			MR_CAS_LATENCY_3,
			MR_BURST_TYPE_SEQUENTIAL,
			MR_BURST_LENGTH_FULL_PAGE
		};
	end
endtask

// SDRAM controller automaton stages
localparam
	STAGE_INIT    = 0,
	STAGE_IDLE    = 1,
	STAGE_REFRESH = 2,
	STAGE_READ    = 3,
	STAGE_WRITE   = 4;

reg [3:0] stage = STAGE_INIT;
reg [COUNTER_WIDTH:0] counter = 'd0;
reg [COUNTER_REFRESH_WIDTH:0] counter_refresh = 'd0;
task goto_when;
	input [3:0] next_stage;
	input [31:0] when;
	begin
		if (counter == when) goto(next_stage);
		else                 counter <= counter + 'd1;
	end
endtask

task goto;
	input [3:0] next_stage;
	begin
		counter <= 0;
		stage <= next_stage;
	end
endtask

// =============================================================================
// Init stage
// =============================================================================
localparam
	INIT_START          = 0,
	INIT_AFTER_200_US   = DELAY_200_US_CYCLE + INIT_START,
	INIT_PRECHARGE_ALL  = 1 + INIT_AFTER_200_US,
	INIT_AUTO_REFRESH_0 = tRP + INIT_PRECHARGE_ALL,
	INIT_AUTO_REFRESH_1 = tRC + tRP + INIT_AUTO_REFRESH_0,
	INIT_AUTO_REFRESH_2 = tRC + tRP + INIT_AUTO_REFRESH_1,
	INIT_AUTO_REFRESH_3 = tRC + tRP + INIT_AUTO_REFRESH_2,
	INIT_AUTO_REFRESH_4 = tRC + tRP + INIT_AUTO_REFRESH_3,
	INIT_AUTO_REFRESH_5 = tRC + tRP + INIT_AUTO_REFRESH_4,
	INIT_AUTO_REFRESH_6 = tRC + tRP + INIT_AUTO_REFRESH_5,
	INIT_AUTO_REFRESH_7 = tRC + tRP + INIT_AUTO_REFRESH_6,
	INIT_SETUP          = tRC + tRP + INIT_AUTO_REFRESH_7,

	INIT_END            = tMRD + INIT_SETUP;

task stage_init;
	begin
		case (counter)
			INIT_START: begin
				command_init();
				dqm <= { HIGH, HIGH, HIGH, HIGH };
				dq_wr <= FALSE;
				counter_refresh <= 'd0;
			end

			INIT_AFTER_200_US: command_nop();
			INIT_PRECHARGE_ALL: command_precharge_all();
			INIT_AUTO_REFRESH_0: command_auto_refresh();
			INIT_AUTO_REFRESH_1: command_auto_refresh();
			INIT_AUTO_REFRESH_2: command_auto_refresh();
			INIT_AUTO_REFRESH_3: command_auto_refresh();
			INIT_AUTO_REFRESH_4: command_auto_refresh();
			INIT_AUTO_REFRESH_5: command_auto_refresh();
			INIT_AUTO_REFRESH_6: command_auto_refresh();
			INIT_AUTO_REFRESH_7: command_auto_refresh();
			INIT_SETUP: command_mode_register_set();

			default: command_nop();
		endcase

		goto_when(STAGE_IDLE, INIT_END);
	end
endtask

reg rd_request_pending;
reg wr_request_pending;
always @(posedge clk)
	if (rst_n == TRUE_n) begin
		rd_request_pending <= FALSE;
		wr_request_pending <= FALSE;
	end else begin
		if (rd_request)
			rd_request_pending <= TRUE;
		else if (stage == STAGE_READ)
			rd_request_pending <= FALSE;

		if (wr_request)
			wr_request_pending <= TRUE;
		else if (stage == STAGE_WRITE)
			wr_request_pending <= FALSE;
	end

// =============================================================================
// Idle stage
// =============================================================================
wire refresh_needed = counter_refresh == REFRESH_CYCLE;
task stage_idle;
	begin
		command_nop();

		if (refresh_needed) begin
			goto(STAGE_REFRESH);
		end else if (rd_request_pending) begin
			goto(STAGE_READ);
		end else if (wr_request_pending) begin
			goto(STAGE_WRITE);
		end else begin
			goto(STAGE_IDLE);
		end
	end
endtask

// =============================================================================
// Refresh stage
// =============================================================================
localparam
	REFRESH_START       = 0,
	REFRESH_END         = tRC + REFRESH_START;

task stage_refresh;
	begin
		counter_refresh <= 'd0;

		case (counter)
			REFRESH_START: command_auto_refresh();
			default: command_nop();
		endcase

		goto_when(STAGE_IDLE, REFRESH_END);
	end
endtask

// =============================================================================
// Burst read stage
// =============================================================================
localparam
	READ_OPEN_ROW       = 0,
	READ_OPEN_COL       = tRCD,
	READ_DATA_START     = tRCD + CAS_LATENCY;

wire [1:0] read_bank = get_bank(rd_address);
wire [7:0] read_col = get_column(rd_address);
wire [10:0] read_row = get_row(rd_address);
reg [8:0] rd_burst_stop;
task stage_read;
	begin
		// Commands sequence
		case (counter)
			READ_OPEN_ROW: begin
				rd_burst_stop <= rd_burst_length + READ_OPEN_COL;
				command_bank_activate(read_bank, read_row);
			end
			READ_OPEN_COL: command_read(read_bank, read_col);
			rd_burst_stop: command_burst_stop();
			rd_burst_stop + 'd1: command_bank_precharge(read_bank);
			default: command_nop();
		endcase
		rd_data <= dq;

		// Data output
		rd_available <=
			counter >= READ_DATA_START &&
			counter <= rd_burst_length + READ_DATA_START;

		goto_when(STAGE_IDLE, rd_burst_stop + CAS_LATENCY + tRP);
	end
endtask

// =============================================================================
// Burst write stage
// =============================================================================
localparam
	WRITE_OPEN_ROW       = 0,
	WRITE_OPEN_COL       = tRCD;

wire [1:0] write_bank = get_bank(wr_address);
wire [7:0] write_col = get_column(wr_address);
wire [10:0] write_row = get_row(wr_address);
reg [8:0] wr_burst_stop;
reg [8:0] wr_precharge;
task stage_write;
	begin
		// Commands sequence
		if (counter == WRITE_OPEN_ROW) begin
			wr_burst_stop <= wr_burst_length + WRITE_OPEN_COL;
			if (wr_burst_length + WRITE_OPEN_COL < tRAS)
				wr_precharge <= tRAS;
			else
				wr_precharge <= wr_burst_length + WRITE_OPEN_COL + 'd1;
			command_bank_activate(write_bank, write_row);
		end else if (counter == WRITE_OPEN_COL) begin
			command_write(write_bank, write_col);
		end else if (counter == wr_burst_stop) begin
			command_burst_stop();
		end else if (counter == wr_precharge) begin
			command_bank_precharge(write_bank);
		end else
			command_nop();

		if (counter >= WRITE_OPEN_COL && counter < wr_burst_stop)
			set_dq(wr_data);

		wr_done <= counter == wr_precharge + tRP;

		goto_when(STAGE_IDLE, wr_precharge + tWR + tRP);
	end
endtask

// =============================================================================
// SDRAM controller automaton
// =============================================================================
always @(posedge clk)
	if (rst_n == TRUE_n) begin
		counter_refresh <= 'd0;
		goto(STAGE_INIT);
	end else begin
		if (~refresh_needed) counter_refresh <= counter_refresh + 'd1;

		case (stage)
			STAGE_INIT: stage_init();
			STAGE_IDLE: stage_idle();
			STAGE_REFRESH: stage_refresh();
			STAGE_READ: stage_read();
			STAGE_WRITE: stage_write();
		endcase
	end

endmodule
