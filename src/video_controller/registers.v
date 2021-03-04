localparam
    VIDEO_NOP              = 'd0,
    VIDEO_SET_BASE_ADDRESS = 'd1,
    VIDEO_SET_FIRST_ROW    = 'd2,
    VIDEO_CURSOR_POSITION  = 'd3,

    COLUMNS                = 'd80,
    COLUMNS_REAL           = 'd128,
    ROWS                   = 'd51,
    CHARATTR_SIZE          = 'd4,
    ROW_SIZE               = COLUMNS_REAL * CHARATTR_SIZE,
    PAGE_SIZE              = ROW_SIZE * ROWS
    ;
