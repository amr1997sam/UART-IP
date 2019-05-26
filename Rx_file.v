module Rx (r_r,d_in,data_out,d_num,s_num,para,R1200,R2400,R4800,R9600,bd_rate,err_p,err_frame);
  //input
  input R1200,R2400,R4800,R9600;   
  input r_r,d_in,d_num,s_num;   
  input [1:0] para;
  input [1:0] bd_rate;   // selector for different clocks
  //output
  output reg [7:0]data_out;
  output reg err_p;    // error for parity
  output reg err_frame;
  
  reg [1:0]stop_count;
  reg [2:0]st;   // state
  reg [4:0]c_clk;    // counter for clk
  reg [2:0]n;  // for state of d_in (counter for n_bit)
  reg [3:0]n_bit;    // number of bits       ////////////a//should use the input signal instead
  reg [7:0]d_out;
  reg clk_r;
 
  // begin by choosing the rate of the clock
  always @(bd_rate,R1200,R2400,R4800,R9600)begin
    if(bd_rate==0)
      clk_r =R1200;
    else if(bd_rate==1)
      clk_r =R2400;
    else if(bd_rate==2)
      clk_r =R4800;
    else 
      clk_r =R9600;
  end//always
  
  // detecting the number of bits
  always @(posedge clk_r)begin   
    if (d_num)
      n_bit=8;
    else
      n_bit=7;
  end//always
  
  always @(posedge clk_r )begin
    if (r_r)begin     // reset
      d_out=0;
      st=0;
      stop_count=0;
      c_clk=0;
      n=0;
      data_out=0;
      err_p=0;
      err_frame=0;
    end//if
    else    // not reset
      case (st)
        0:begin   // idle state
          if(d_in)
            st=0;
          else
            st=1;
          end//case:0
        1:begin  // start state
          d_out=0;    
          if (c_clk<7)   // count 7 clk then read again
            c_clk=c_clk+1;
          else if (d_in) begin //error in start
            err_frame=1;
            c_clk=0;
            st=0;
          end//else if           
          else begin
            c_clk=0;
            st=2;
            err_frame=0;
          end//else
        end//case:1
        2:begin       // data state 
          if (c_clk<15)
            c_clk=c_clk+1;
          else if (n==n_bit-1)begin   // last bit 
            d_out[n]=d_in;
            n=0;
            c_clk=0;
            if(para==2'b00)
              st=4;     // stop as no parity
            else
              st=3;     // parity state
          end//else if
          else begin
            d_out[n]=d_in;
            st=2;
            c_clk=0;
            n=n+1;
          end//else
        end//case:2
        3:begin    // parity state
          if (c_clk<15)
            c_clk=c_clk+1;
          else if (para==2'b10)begin         // check parity
            if (^d_out ==0)// even parity
              if(d_in)
                err_p=1;
              else
                err_p=0;
            else if(d_in)
              err_p=0;
            else
            err_p=1;
          end//else if
          else if (^d_out ==0)       //odd parity
            if(d_in)
              err_p=0;
            else
              err_p=1;
          else
            if(d_in)
              err_p=1;
            else
              err_p=0; 
          st=4;
          c_clk=0;
        end//case:3
        4:begin     // stop state
          if(s_num)begin
            if(stop_count<2)begin
              if (c_clk<15)
                c_clk=c_clk+1;
              else begin
                c_clk=0; 
                if (d_in)begin     // check stop
                  stop_count=stop_count+1;
                  st=4;
                end//if
                else begin      //stop data not 1
                err_frame=1;
                st=0;
                end//else
              end//else
            end//if
            else begin
              st=0;
              stop_count=0;
              c_clk=0;
            end//else
          end//if
          else if (c_clk<15)
            c_clk=c_clk+1;
          else begin
            c_clk=0;
            if (d_in)
              st=0;
            else begin    // error in stop
              err_frame=1;
              st=0;
            end//else
          end//else
          data_out=d_out; 
        end//case:4
      default : st=0;
    endcase
  end//always
endmodule
                
              
              
                  
                  
                  
                  
                
      
      
  
