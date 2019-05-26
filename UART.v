`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
module UART(clk, rst, bd_sel, prty_sel, stop_sel, data_bit_sel, data_in, edit, Esec, Emin, Ehour, Eday, Emonths, RX, TX, data_out, err_prty, err_frame, sh,alarm, Hsec, Hmin, Hhour, Hday, Hmon);
//selectors, clk, data_in,data_out, errors
////////////////////////////////////////////////////////////////////////// declarations.
input         clk;
input          rst;
//selectors
input  [1:0]   bd_sel, 
               prty_sel;
input          stop_sel, 
               data_bit_sel;
//seial data 
input         RX;

output        TX;

// parallel data 
input   [7:0]  data_in;
output  [7:0]  data_out;
//flags
output   err_prty, 
        err_frame,
        sh,
        alarm;

wire       min15;

wire  baud_clk;      //1200 baud of Tx -- note it is the most devided clk till now just for test

input edit;         // edit time and date 
input Esec;        //seconds edit  1
input Emin;       //minutes edit   2 
input Ehour;     //hour edit       3
input Eday;     //day edit         4
input Emonths; //months edit       5


output wire [5:0]  Hsec; //Counter
output wire [5:0]  Hmin; //Counter
output wire [4:0]  Hhour; //Counter
output wire [4:0]  Hday; //Counter
output wire [3:0]  Hmon; //Counter

////////////////////////////////////////////////////////////////////////// top Tx inst.
TxTop tx (clk, rst, data_in, prty_sel, stop_sel, data_bit_sel, bd_sel, min15, TX, baud_clk);

////////////////////////////////////////////////////////////////////////// tiop Rx inst.
RxTop rx (clk,rst, bd_sel, prty_sel, stop_sel, data_bit_sel, RX, data_out, err_prty, err_frame, sh, alarm);

////////////////////////////////////////////////////////////////////////// clock inst.
Watch_reload tim (
 rst,
 baud_clk, 
 clk,     

 edit,   
 Esec,    
 Emin,    
 Ehour,   
 Eday,    
 Emonths, 

 Hsec, 
 Hmin, 
 Hhour,
 Hday, 
 Hmon, 

 min15
);
endmodule


