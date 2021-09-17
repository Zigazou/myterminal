<?xml version="1.0" encoding="UTF-8"?>
<Project>
    <Project_Created_Time>2020-09-01 19:32:05</Project_Created_Time>
    <TD_Version>4.6.25304</TD_Version>
    <UCode>10101000</UCode>
    <Name>myterminal</Name>
    <HardWare>
        <Family>EG4</Family>
        <Device>EG4S20BG256</Device>
    </HardWare>
    <Source_Files>
        <Verilog>
            <File>al_ip/clock.v</File>
            <File>src/video_controller.v</File>
            <File>src/serial_in.v</File>
            <File>src/embedded_sdram.v</File>
            <File>al_ip/font_ram.v</File>
            <File>src/font.v</File>
            <File>al_ip/charattr_row.v</File>
            <File>al_ip/pixels.v</File>
            <File>src/terminal_stream.v</File>
            <File>src/simple_fifo.v</File>
            <File>src/ps2_receiver.v</File>
            <File>src/serial_out.v</File>
            <File>src/ps2_keyboard_state.v</File>
            <File>src/ps2_keyboard_ascii.v</File>
            <File>src/ps2_scan_code_set2_fr.v</File>
            <File>src/ps2_ascii_codes.v</File>
            <File>src/sequence_to_bytes.v</File>
            <File>src/muxer.v</File>
            <File>src/register_muxer.v</File>
            <File>src/ps2_mouse_ascii.v</File>
            <File>src/ps2_mouse_state2.v</File>
            <File>src/ps2_mouse_receiver.v</File>
            <File>al_ip/cursor_ram.v</File>
            <File>src/myterminal.v</File>
        </Verilog>
        <ADC_FILE>src/myterminal.adc</ADC_FILE>
        <SDC_FILE>src/myterminal.sdc</SDC_FILE>
        <CWC_FILE/>
    </Source_Files>
    <TOP_MODULE>
        <LABEL/>
        <MODULE>myterminal</MODULE>
        <CREATEINDEX>auto</CREATEINDEX>
    </TOP_MODULE>
    <Device_Settings>
        <EG4X>
            <program_b>gpio</program_b>
        </EG4X>
    </Device_Settings>
    <Property>
        <RtlProperty>
            <opt_mux>on</opt_mux>
        </RtlProperty>
        <GateProperty/>
        <PlaceProperty/>
    </Property>
    <Project_Settings>
        <Step_Last_Change>2021-09-16 21:03:37</Step_Last_Change>
        <Current_Step>60</Current_Step>
        <Step_Status>true</Step_Status>
    </Project_Settings>
</Project>
