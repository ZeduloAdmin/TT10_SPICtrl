`timescale 1ns / 1ps

module tb;
    parameter real    CLK_FREQ      = 50 * 1000000.0;
    parameter integer SPICLK_TIME      = 100000;

    localparam real CLK_DURATION = (1000000000.0 / CLK_FREQ) / 2.0;
    localparam real RESET_DURATION = CLK_DURATION * 4.0;
    localparam real BIT_DURATION = (1000000000.0 / SPICLK_TIME);
    localparam real BYTE_DURATION = BIT_DURATION * 4.0;
    localparam real DELAY = 0;

//    reg [ 7 : 0 ] ui_in;
//    reg [ 7 : 0 ] uo_out;
     
    reg  clk         = 1'b0;
    reg  rst_n         = 1'b1;
    reg  spi_mosi    = 1'b0;
    reg  spi_clk    = 1'b0;
    reg	 spi_cs	    = 1'b1;
    reg  spi_miso;
    reg  led_status;
    reg	 led_reset;
    reg	 debug;
 
    always #CLK_DURATION clk = !clk;
//    assign ui_in = { 6'b0000_00, spi_mosi, spi_clk};
//    assign {debug, led_reset, led_status, spi_miso} = uo_out[3:0];

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        spi_clk = 1;
        #RESET_DURATION           rst_n        = 1'b1;
        #RESET_DURATION           rst_n        = 1'b0;
        #RESET_DURATION           rst_n        = 1'b1;
        for (int i = 0; i < 1 * 20; i++) begin

	    #BIT_DURATION    spi_cs = 0;
		//0100 0011
            #BIT_DURATION    spi_clk = 0; //bit7
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit6
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit5
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit4
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit3
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit2
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit1
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit0
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //
      	    #BIT_DURATION    spi_cs = 1;

            #BYTE_DURATION    spi_clk = 0; //next byte
       	    #BIT_DURATION    spi_cs = 0;
       	    
            #BIT_DURATION    spi_clk = 0; //bit7
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit6
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit5
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit4
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit3
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit2
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit1
            #BIT_DURATION    spi_mosi = 1; //
            #BIT_DURATION    spi_clk = 1; //

            #BIT_DURATION    spi_clk = 0; //bit0
            #BIT_DURATION    spi_mosi = 0; //
            #BIT_DURATION    spi_clk = 1; //

	    #BIT_DURATION    spi_cs = 1;
	    
            #BYTE_DURATION    spi_clk = 0; //next byte
        end

        $finish;
    end
 
    //nanospi_top top(clk, rst_n, spi_mosi, spi_clk, spi_miso, led_status, led_reset, debug);

    reg [6:0] ou_out_dest;
    reg [7:0] uio_out_dest;
    reg [7:0] uio_oe_dest;

    tt_um_zedulo_spitest1 top({spi_mosi, spi_clk, spi_cs, 5'h0}, {spi_miso, ou_out_dest[6:0]}, 8'h00, uio_out_dest[7:0], uio_oe_dest, 1'b1, clk, rst_n);
  
 /*  
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
*/



endmodule
