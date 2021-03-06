`ifndef DEFINE_STATE

// This defines the states

typedef enum logic [4:0] {
	S_WAIT_NEW_PIXEL_ROW,
	S_NEW_PIXEL_ROW_DELAY_1,
	S_NEW_PIXEL_ROW_DELAY_2,
	S_NEW_PIXEL_ROW_DELAY_3,
	S_NEW_PIXEL_ROW_DELAY_4,
	S_NEW_PIXEL_ROW_DELAY_5,
	S_FETCH_PIXEL_DATA_0,
	S_FETCH_PIXEL_DATA_1,
	S_FETCH_PIXEL_DATA_2,
	S_FETCH_PIXEL_DATA_3,
	S_FETCH_PIXEL_DATA_4,
	S_FETCH_PIXEL_DATA_5,
	S_FETCH_PIXEL_DATA_6,
	S_FETCH_PIXEL_DATA_7,
	S_IDLE,
	S_FILL_SRAM_GREEN_02,
	S_FILL_SRAM_BLUE_02,
	S_FILL_SRAM_GREEN_13,
	S_FILL_SRAM_BLUE_13,
	S_FILL_SRAM_RED_01,
	S_FILL_SRAM_RED_23,
	S_FINISH_FILL_SRAM
} state_type;

`define DEFINE_STATE 1
`endif
