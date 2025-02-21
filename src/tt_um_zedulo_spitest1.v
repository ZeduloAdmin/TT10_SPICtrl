/*
 * Copyright (c) 2025 Zedulo.com
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none


module tt_um_zedulo_spitest1 (
    input  wire [7:0] ui_in /*verilator public*/,    // Dedicated inputs
    output wire [7:0] uo_out /*verilator public*/,   // Dedicated outputs
    input  wire [7:0] uio_in /*verilator public*/,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk /*verilator public*/,      // clock
    input  wire       rst_n /*verilator public*/     // reset_n - low to reset
);

	// Assign / list all unused inputs to prevent warnings
	assign uio_out = 0;
	assign uio_oe  = 0;
	wire _unused = &{ena, uio_in, ui_in[7:3], 1'b0};

	reg [3:0] sub_clk; //clk=100MHz, sub_clk[0]=50MHz, sub_clk[1]=25MHz, sub_clk[2]=12.5MHz sub_clk[3]=6.25MHz


	//assign uo_out[0] =  //miso
	//assign uo_out[1] =  //debug
	assign uo_out[2] = clk; //clock mirror
	assign uo_out[5:3] = 3'h0; //unused
	//assign uo_out[6] = //status
	//assign uo_out[7] = //reset status

	wire spi_mosi, spi_clk, spi_cs;
	assign spi_mosi = ui_in[0];
	assign spi_clk  = ui_in[1];
	assign spi_cs   = ui_in[2];

/*      input  wire clk
        input  wire rst_n
        input  wire spi_mosi
        input  wire wspi_clk
        input  wire wspi_cs
        output wire wspi_miso
        output wire wled_status
        output wire wled_reset
        output wire wdebug */
	//                    clk  reset  mosi      spi clk   spi cs    miso       status     reset      debug
	nanospi_top spidevice(clk, rst_n, spi_mosi, spi_clk, spi_cs, uo_out[0], uo_out[6], uo_out[7], uo_out[1]);

endmodule
