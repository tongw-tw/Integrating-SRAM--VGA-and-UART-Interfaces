/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module SRAM_BIST (
	input logic Clock,
	input logic Resetn,
	input logic BIST_start,
	
	output logic [17:0] BIST_address,
	output logic [15:0] BIST_write_data,
	output logic BIST_we_n,
	input logic [15:0] BIST_read_data,
	
	output logic BIST_finish,
	output logic BIST_mismatch
);

BIST_state_type BIST_state;

`ifdef SIMULATION
BIST_state_type previous_BIST_state;
`endif

logic BIST_start_buf;

// mode is 0 for the first burst (ALL1 in even locations) and mode is 1 for the second burst (ALL1 in odd locations)
logic BIST_mode;
assign BIST_write_data = BIST_mode || (BIST_state == S_DELAY_3)|| (BIST_state == S_DELAY_4)? 
			(BIST_address[0] ? ALL1 : ALL0) : (BIST_address[0] ? ALL0 : ALL1);

// reference data to be used for comparison against what is read from the memory
logic [15:0] BIST_reference_data;
assign BIST_reference_data = BIST_write_data;

// The BIST engine
always_ff @ (posedge Clock or negedge Resetn) begin
	if (Resetn == 1'b0) begin
		BIST_state <= S_IDLE;
		BIST_mismatch <= 1'b0;
		BIST_finish <= 1'b0;
		BIST_address <= 18'd0;
		BIST_we_n <= 1'b1;
		BIST_start_buf <= 1'b0;
		BIST_mode <= 1'b0;
	end else begin
		BIST_start_buf <= BIST_start;
		
		case (BIST_state)
		S_IDLE: begin
			if (BIST_start & ~BIST_start_buf) begin
				// Start the BIST engine
				BIST_address <= 18'd0;
				BIST_we_n <= 1'b0;
				BIST_mismatch <= 1'b0;
				BIST_finish <= 1'b0;
				BIST_mode <= 1'b0;
				BIST_state <= S_WRITE_CYCLE;
			end else begin
				BIST_address <= 18'd0;
				BIST_we_n <= 1'b1;
				BIST_finish <= 1'b1;				
			end
		end
		S_DELAY_1: begin
			BIST_address[17:0] <= ~BIST_address[17:0];
			BIST_state <= S_DELAY_2;
		end
		S_DELAY_2: begin
			BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2;
			BIST_state <= S_READ_CYCLE;
		end
		S_WRITE_CYCLE: begin
			if (!BIST_mode) begin
				if (!BIST_address[0]) 
					BIST_address[17:0] <= ~BIST_address[17:0];	// switch from even to odd location
				else 
					BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2; // advance from odd to next even location
				if (BIST_address == 18'h00001) begin
					BIST_we_n <= 1'b1;
					BIST_state <= S_DELAY_1;
				end
			end else begin
				if (BIST_address[0]) 
					BIST_address[17:0] <= ~BIST_address[17:0];	// switch from odd to even location
				else 
					BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2; // advance from even to next odd location
				if (BIST_address == 18'h00000) begin
					BIST_we_n <= 1'b1;
					BIST_address <= 18'h00001;
					BIST_state <= S_DELAY_1;
				end
			end
		end
		S_READ_CYCLE: begin
			if (BIST_read_data != BIST_reference_data) 
				BIST_mismatch <= 1'b1;
			if (!BIST_mode) begin
				if (!BIST_address[0]) 
					BIST_address[17:0] <= ~BIST_address[17:0];
				else 
					BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2;
				if (BIST_address == 18'h00001) begin
					BIST_we_n <= 1'b0;		// enable the write mode for the second burst
					BIST_address <= 18'h00001;	// overrides the previous assignment 
									// start the second burst from location 18'd1
					BIST_state <= S_DELAY_3;
				end
			end else begin
				if (BIST_address[0]) 
					BIST_address[17:0] <= ~BIST_address[17:0];
				else 
					BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2;
				if (BIST_address == 18'h00000)
					BIST_state <= S_DELAY_3;
			end
		end
		S_DELAY_3: begin
			if (BIST_read_data != BIST_reference_data) 
				BIST_mismatch <= 1'b1;
			BIST_address[17:0] <= ~BIST_address[17:0];
			BIST_state <= S_DELAY_4;
		end
		S_DELAY_4: begin
			if (BIST_read_data != BIST_reference_data) 
				BIST_mismatch <= 1'b1;
			if (BIST_mode) begin
				BIST_state <= S_IDLE;
				BIST_finish <= 1'b1;
			end else begin
				BIST_mode <= 1'b1;
				`ifdef SIMULATION
					$write("\n\nSwitching BIST mode at time %t\n\n\n", $realtime);
				`endif
				BIST_address[17:0] <= ~BIST_address[17:0] + 18'd2;
				BIST_state <= S_WRITE_CYCLE;
			end
		end
		default: BIST_state <= S_IDLE;
		endcase
	end
end

endmodule
