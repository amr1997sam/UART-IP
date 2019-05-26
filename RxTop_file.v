`timescale 1ns / 1ps

module RxTop(clk,rst, bd_sel, prty_sel, stop_sel, data_bit_sel, data_in_Rx, data_out_Rx, err_prty, err_frame, sh, alarm);
//////////////////////////////////////////////////////////////////////////////////////////////////////// in / out declarations
input            clk;
input            rst;
//selectors
input [1:0]      bd_sel, 
                 prty_sel;
input            stop_sel, 
                 data_bit_sel;
//seial data in
input            data_in_Rx; 

// parallel data out
output  [7:0] data_out_Rx;
//flags
output        err_prty, 
                 err_frame,
                 sh,
                 alarm;

//////////////////////////////////////////////////////////////////////////////////////////////////////// wires
//baud rates
wire  r1200, r2400, r4800, r9600;

//////////////////////////////////////////////////////////////////////////////////////////////////////// freq. divider inst.
RX_div dut1(
    clk,rst,

    r9600,      //9600 baud rate
    r4800,     //2400 baud rate
    r2400,    //4800 baud rate
    r1200    //1200 baud rate
);

//////////////////////////////////////////////////////////////////////////////////////////////////////// Rx inst. 
Rx dut2 (rst, data_in_Rx, data_out_Rx, data_bit_sel, stop_sel, prty_sel, r1200, r2400, r4800, r9600, bd_sel, err_prty, err_frame);

//////////////////////////////////////////////////////////////////////////////////////////////////////// error-check unit inst.
check_temp dut3 (sh, alarm, data_out_Rx); 

endmodule
