`timescale 1ns / 1ps

module TxTop(clk, rst, in_data, para, s_num, d_num, bd_rate, start, out_data, T1200);
/////////////////////////////////////////////////////////////////////////////////// inputs / outputs
input       clk, rst; 
input       start;
input [7:0] in_data;
//selectors
input [1:0] para, bd_rate;
input       s_num, d_num;

output      out_data;
output      T1200;

wire  T2400, T4800, T9600;
/////////////////////////////////////////////////////////////////////////////////// frqunecy divider instance
freq dut1 (clk, rst, T1200, T2400, T4800, T9600);

/////////////////////////////////////////////////////////////////////////////////// Tx instance
Tx dut2 (rst, in_data, out_data, para, s_num, d_num, bd_rate, T1200, T2400, T4800, T9600, start);
endmodule
