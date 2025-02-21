/*
 * Copyright (c) 2025 Zedulo.com
 * SPDX-License-Identifier: Apache-2.0
 */

/*
 Nano SPI controller, all SPI commands are 4 bit long, arg is 4 bits
 Returns top bits as command with bit 7 inverted.
	CMD:	ARG:		Definition:
	STATUS	field		Returns status for the specific field
	SET	IO pin		Sets the specified output pin
	CLEAR	IO pin		Clears the specified output pin
	TARGET	reg/addr/io	Specify the target for read/write operations
	WRITE	data		Writes to the set target
	READ	n/a		Reads from the set target

*/


`define CMD_STATUS 4'h0
`define CMD_SET 4'h1
`define CMD_CLEAR 4'h2
`define CMD_TARGET 4'h3
`define CMD_WRITE 4'h4
`define CMD_READ 4'h5

`default_nettype none


module nanospi_top (
	input  wire clk /*verilator public*/,	// clock
	input  wire rst_n /*verilator public*/,	// reset_n - low to reset

	input  wire spi_mosi /*verilator public*/,    	//
	input  wire wspi_clk /*verilator public*/,    	//
	input  wire wspi_cs /*verilator public*/,    	//
	output wire wspi_miso /*verilator public*/,   	//	

	output wire wled_status /*verilator public*/,   	//optional
	output wire wled_reset /*verilator public*/,   	//optional
	output wire wdebug /*verilator public*/   	//optional
);

	reg spi_clk_buff[1:0];
	wire spi_clk;
	assign spi_clk = spi_clk_buff[0];
	wire spi_clk_stabile;
	assign spi_clk_stabile = spi_clk_buff[1] == spi_clk_buff[0];

	reg spi_miso;
	assign wspi_miso = spi_miso;	
	
	reg led_status;
	assign wled_status = led_status;
	reg led_reset;
	assign wled_reset = led_reset;
	reg debug;
	assign wdebug = debug;

////////////////////////// TT definitions above, don't change!


	reg data_ready; //data is ready for use
	reg arm_tx; //put out first tx bit on miso
	reg spi_completed; //tranmission completed flag, rx data in data_reg
	reg prev_spi_clk; //last state of cpi_clk, to detect edges
	reg [7:0] main_reg; //main shiftreg
	reg [2:0] spi_count;
	
	reg target; //set by TARGET, decides what bits should be written by WRITE
	reg [7:0] storage; //let us save a byte for READ/WRITE access, high/low bits set by TARGET
	

	always @ (posedge clk)
	begin
		//$strobe("spi_clk %d", spi_clk);
		
		//reset sequence
		if(rst_n == 0)begin //0 == reset
			//$display("Reset");
			//SPI regs
			main_reg <= 8'h59;  //no need to clear other regs
			led_reset <= 1'h1; //LED2 on
			led_status <= 1'h1;			
			debug <= 0;
		end
		else if(wspi_cs == 1'b1) begin
			prev_spi_clk <= 1;
			spi_completed <= 0;
			arm_tx <= 1;
			spi_clk_buff[0] <= wspi_clk;
			spi_clk_buff[1] <= wspi_clk;
			data_ready <= 0;
			spi_count <= 0;
		end
		//normal operation
		else begin
			spi_clk_buff[0] <= wspi_clk;
			spi_clk_buff[1] <= spi_clk_buff[0];
			
			led_reset <= 1'h0; //LED2 off			
			
			if(data_ready == 1)begin 
			
				`ifdef _VERILATOR
				$display("->Target exec. reg %h", main_reg[7:0]);
				//$display("Exec CMD %h with arg %h", main_reg[7:4], main_reg[3:0]);
				`endif

				data_ready <= 0;				
				//main_reg[7:0] <= 8'h99;
				arm_tx <= 1;
				debug <= 1'b0;

				case (main_reg[7:4])
					`CMD_STATUS : begin
						main_reg[0] <= 1'h0; //input_pin;
						main_reg[3:1] <= 3'h0;
						//$display("STATUS arg %h", data_reg[3:0]);
					end

					`CMD_SET : begin
						main_reg[3:0] <= 4'h1;
						//output_pin <= 1;
						led_status <= 1'h0; //LED1 on
						//$display("SET arg %h", data_reg[3:0]);
					end

					`CMD_CLEAR : begin
						main_reg[3:0] <= 4'h1;
						//output_pin <= 0;
						led_status <= 1'h1; //LED1 off
						//$display("CLEAR arg %h", data_reg[3:0]);
					end

					`CMD_TARGET : begin
						main_reg[3:0] <= 4'h1;
						target <= main_reg[0];
						//$display("TARGET arg %h", data_reg[3:0]);
					end

					`CMD_READ : begin
						if(target == 0)main_reg[3:0] <= storage[3:0];
						else main_reg[3:0] <= storage[7:4];
						//$display("READ arg %h", data_reg[3:0]);
					end

					`CMD_WRITE : begin
						main_reg[3:0] <= 4'h1;
						if(target == 0)storage[3:0] <= main_reg[3:0];
						else storage[7:4] <= main_reg[3:0];
						//$display("WRITE arg %h", data_reg[3:0]);
					end
					
					default : begin //do nothing
						//$display("UNKNOWN CMD, arg %h", data_reg[3:0]);
						main_reg[3:0] <= 4'hf;
					end
				endcase
			end //
			else if(spi_completed == 1)begin 
				//spi_count <= 0;
				spi_completed <= 0;
				data_ready <= 1;
			end
			else if(arm_tx == 1)begin
				spi_miso <= main_reg[7];
				arm_tx <= 0;
			end
			else if(spi_clk_stabile == 1 & spi_clk == 1 & prev_spi_clk == 0)begin
				prev_spi_clk <= 1;

				main_reg[7] <= main_reg[6];
				main_reg[6] <= main_reg[5];
				main_reg[5] <= main_reg[4];
				main_reg[4] <= main_reg[3];
				main_reg[3] <= main_reg[2];
				main_reg[2] <= main_reg[1];
				main_reg[1] <= main_reg[0];
				main_reg[0] <= spi_mosi;

				if(spi_count == 7)begin 
					led_status <= 1'h0; //LED1 off
					spi_completed <= 1;
					debug <= 1'b1;
					//spi_count <= 3'h0;
				end
				
				spi_count <= spi_count + 3'h1;
			end
			// SPI Clock low, put out new data
			else if(spi_clk_stabile == 1 & spi_clk == 0 & prev_spi_clk == 1)begin
				spi_miso <= main_reg[7];
				prev_spi_clk <= 0;
			end
			else begin				
				spi_completed <= spi_completed;
				prev_spi_clk <= prev_spi_clk;
				spi_count <= spi_count;
				spi_miso <= spi_miso;
				arm_tx <= arm_tx;
				debug <= debug;
			end
			
		end

	end


endmodule

 
