/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

// This is the top module
// It connects the BIST and the SRAM controller
module exercise1 (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_I,           // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// LEDs                              ////////////
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs

		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[17:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O                  // SRAM output logic enable
);

logic resetn;

// For Push button
logic [3:0] PB_pushed;

// For SRAM Controller
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

// For SRAM_BIST
logic [17:0] BIST_address;
logic [15:0] BIST_write_data;
logic BIST_we_n;
logic [15:0] BIST_read_data;
logic BIST_mismatch;
logic BIST_finish;

assign resetn = ~SWITCH_I[17] && SRAM_ready;

// Push Button unit
PB_Controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_I),	
	.PB_pushed(PB_pushed)
);

// SRAM unit
SRAM_Controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);

// BIST engine
SRAM_BIST BIST_unit (
	.Clock(CLOCK_50_I),
	.Resetn(resetn),
	.BIST_start(PB_pushed[0]),
	.BIST_address(BIST_address),
	.BIST_write_data(BIST_write_data),
	.BIST_we_n(BIST_we_n),
	.BIST_read_data(BIST_read_data),
	.BIST_finish(BIST_finish),
	.BIST_mismatch(BIST_mismatch)
);

// Use the switches to emulate problems with the SRAM
assign SRAM_address = (SWITCH_I[0] && SRAM_we_n == 1'b0) ? {BIST_address[17:1], 1'b0} : BIST_address;
assign SRAM_write_data = (SWITCH_I[1]) ? {1'b0, BIST_write_data[14:0]} : BIST_write_data;
assign SRAM_we_n = (SWITCH_I[2]) ? 1'b1 : BIST_we_n;
assign BIST_read_data = (SWITCH_I[3]) ? {1'b0, SRAM_read_data[14:0]} : SRAM_read_data;

assign LED_GREEN_O = {~resetn, 1'b0, SWITCH_I[3:0], BIST_we_n, BIST_finish, BIST_mismatch};

endmodule
