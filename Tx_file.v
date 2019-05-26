module Tx (r_t, in_data, out_data, para, s_num, d_num, bd_rate, T1200, T2400, T4800, T9600, start);
  
  parameter s=1,d=7,s_idle=0,s_start=1,s_data=2,s_parity=3,s_stop=4; //sates for the fsm diagram 
  
  input r_t;
  input [1:0] bd_rate;   // selector for different clocks
  input s_num,d_num;     //selector for stop and data width
  input [1:0] para;      //selector for the parity check
  input [d:0] in_data;   //data received from sensor
  input T1200,T2400,T4800,T9600;  
  input start;       //signal that indicate the begining of the received data each "15 min"  
               
  output reg  out_data;     //serial data shifted to the receiver in UART
  
  reg clk_t; 
  reg [d:0] data;        // data holding for parity check
  reg [2:0] M_ST;              //the main state 
  reg [2:0] data_count;        //counting each data shifted to the receiver
  reg [1:0] stop_count;        //counting each stop bit shifted in serial
  
  
  
  // begin by choosing the rate of the clock
  always@* begin//1
    if(bd_rate==0)
      clk_t =T1200;
    else if(bd_rate==1)
      clk_t =T2400;
    else if(bd_rate==2)
      clk_t =T4800;
    else if(bd_rate==3)
      clk_t =T9600;
  end//always1

 //holding the input data for parity check     
always @ (posedge start)begin//2
data=in_data;
end//always2
  
always @(posedge clk_t) begin //3
  case(r_t) 
    1:begin         // a reset at the begining of the system should be done
      M_ST<=s_idle;
      data_count<=0;
      stop_count<=0;
      out_data<=1;
      end//case:1
    0:begin        // begin the fsm
    
    
      case(M_ST)               
        s_idle:begin
          out_data<=1;      // always "idle=1"
          if(start==0)
            M_ST<=s_idle;  //no data arrived yet from the sensor
          else begin
            M_ST<=s_start;  //data arrived ,start the system
            out_data<=0;
          end//else
        end//case:s_idle
        s_start: begin
          if(data_count==0) begin  //waiting for one clock cycle then going to the next state "stand by"
            M_ST<=s_data;
            out_data<=data[data_count];    // first data shifted by the sensor
          end//if
          else
            M_ST<=s_start;
        end//case:s_start
        s_data: begin
          out_data<=data[data_count+1];    //shifting data
          if (d_num==1) begin              //in case of 8 bits data
            if(data_count<7) begin
              data_count<=data_count+1;
              M_ST<=s_data;
            end//if
            else begin
              data_count<=0;
              if(para==2'b00) begin        //checking if the parity check is working or not
                out_data<=1;
                M_ST<=s_stop;         //if not then go to the last state "stop"
              end//if
              else begin
                if (para==2'b10)begin                   // even parity
                  if(^data==0)begin              
                    out_data<=0;                // if the number of ones is even
                    M_ST<=s_parity;
                  end//if
                  else begin
                    out_data<=1;                 // if the number of ones is odd
                    M_ST<=s_parity;
                  end//else
                end//else
                else if(para==2'b01)begin             // odd parity
                  if(^data==0)begin
                    out_data<=1;                  // if the number of ones is even
                    M_ST<=s_parity;
                  end//if
                  else begin
                    out_data<=0;                  // if the number of ones is odd
                    M_ST<=s_parity;
                  end//else
                end//else
            end//else 
          end//if
        end//if
        else begin                             // in case of 7 bits data
          if(data_count<6)begin
            data_count<=data_count+1;
            M_ST<=s_data;
          end//if
          else begin
            data_count<=0;
            if(para==2'b00)begin        //checking if the parity check is working or not
              out_data<=1;
              M_ST<=s_stop;        //if not then go to the last state "stop" 
            end//if
            else begin
              if (para==2'b10)begin                  // even parity
                if(^data[6:0]==0)begin
                  out_data<=0;                // if the number of ones is even
                  M_ST<=s_parity;
                end//if                
                else begin
                  out_data<=1;                // if the number of ones is odd
                  M_ST<=s_parity;
                end//else              
              end//if
              else if(para==2'b01)begin          // odd parit
                if(^data[6:0]==0)begin
                  out_data<=1;                // if the number of ones is even
                  M_ST<=s_parity;
                end//if
                else begin
                  out_data<=0;                // if the number of ones is odd
                  M_ST<=s_parity;
                end//else
              end//elseif
            end//else        
          end//else
        end//else       
    end//case:s_data
    s_parity:begin           //leave the signal for one clock cycle
              M_ST<=s_stop;
              out_data<=1;
    end//case:s_parity
    s_stop: begin       //final state "stop"
      out_data<=1;
      if(s_num)begin     //in case of 2 bits
        if(stop_count<1)begin
          out_data<=1;
          stop_count<=stop_count+1;
          M_ST<=s_stop;
        end//if
        else begin
          stop_count<=0;
          out_data<=1;
          M_ST<=s_idle;
        end//else
      end//if        
      else begin                //in case of 1 bit
        out_data<=1;
        stop_count<=0;
        M_ST<=s_idle;       //going back to the "idle state" for waiting the next input data from sensor
      end//else
    end//case:s_stop
    default:M_ST<=s_idle;  // default in case of any error (going back to idle state)       
    endcase//case:M_st
    end//CASE:0:r_t
    endcase//case:r_t
  end//always3
endmodule
  
                          
              
            
          
              
             
                
        
              
      
      
      
     
