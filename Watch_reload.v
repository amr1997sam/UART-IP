
module Watch_reload(
input       rst,
input  baud_clk,      //1200 baud of Tx -- note it is the most devided clk till now just for test
input      MH50,     //50MHz clk of system 

input edit,         // edit time and date 
input Esec,        //seconds edit  1
input Emin,       //minutes edit   2 
input Ehour,     //hour edit       3
input Eday,     //day edit         4
input Emonths, //months edit       5


output reg [5:0]  Hsec, //Counter
output reg [5:0]  Hmin, //Counter
output reg [4:0] Hhour, //Counter
output reg [4:0]  Hday, //Counter
output reg [3:0]  Hmon, //Counter



output reg min15

 
);

reg  sec; //seconds clock
reg [25:0]  Qsec; //Counter
//seconds clock  //50MH with new Qsec if recomended
always @ (posedge(baud_clk), posedge(rst) , posedge(edit))   // trig of reset event handler & 1200 bauds clock to implement 1 sec
begin
    if (rst == 1'b1 | edit == 1'b1) begin // resetting counter
        Qsec  <= 25'b0; 
        sec <= 1'b0;
    end
    else begin
     if (Qsec == 25'd600) begin //017D7840 for 50MH
     Qsec  <= 25'b0; 
     sec <= ~sec; 
        end 
        else begin
       Qsec <= Qsec + 25'd1;
        end
    end
end

//15 min counter 
//////////////////////////////////////////////////////////////////////////////////
reg [20:0] Qpul;//Counter
//15 pulutes pulse block 1
always @ (posedge(baud_clk))   // trig of reset event handler & 1200 bauds clock to implement 1 pul
begin
    if (rst == 1'b1 | edit == 1'b1) begin // resetting counter
        min15 <= 1'b0;
    end
    else begin
    case (Qpul)
    21'd50 : min15 <= 1'b1; // 'h107ac0
    21'd52 : min15 <= 1'b0;// 'h107ac2
    endcase
    end
end


//15 pulutes pulse block 2
always @ (posedge(baud_clk)) begin   // trig of reset event handler & 1200 bauds clock to implement 1 pul
if ((Qpul == 21'd53)| (rst == 1'b1) | (edit == 1'b1)) begin //'h107ac3
Qpul  <= 21'b0; 
end
else begin
Qpul <= Qpul + 21'd1;
end
end
//////////////////////////////////////////////////////////////////////////////////


//sec counter 
wire sec1; 
assign sec1 = ((Esec & edit) | (~(edit) & sec));
always @ (posedge(sec1) , posedge(rst) )   // trig of reset event handeler 
begin
    if (rst == 1'b1) begin // resetting counter
        Hsec  <= 6'b0; 
    end
   // else begin
   // Hsec <= Hsec + 5'b1 ; 
    else begin
      if (edit == 1'b1 && Esec == 1'b1) begin
             if (Hsec  == 6'd59) begin
              Hsec  <= 6'b0; end 
              else begin 
              Hsec <= Hsec + 6'b1 ;
              end
       end   
       else begin
         if (Hsec  == 6'd59) begin
           Hsec  <= 6'b0; end 
           else begin
           Hsec <= Hsec + 6'b1 ;
           end
       end  
    end 

end 
//////////////////////////////////////////////////////////////////////////////////

//min counter 
wire min1; 
assign min1 = ((Emin & edit) | (~(edit) & sec));
always @ (posedge(min1) , posedge(rst) )   // trig of reset event handeler 
begin
    if (rst == 1'b1) begin // resetting counter
        Hmin  <= 6'b0; 
    end
    else begin
      if (edit == 1'b1 && Emin == 1'b1) begin
             if (Hmin  == 6'd59) begin
              Hmin  <= 6'b0; end 
              else begin 
              Hmin <= Hmin + 6'b1 ;
              end
       end   
       else begin
         if (Hmin  == 6'd59 && Hsec  == 6'd59) begin                         ///get reset where 
           Hmin  <= 6'b0; end 
           else begin
          if (Hsec == 6'd59) begin Hmin <= Hmin + 6'b1 ; end
           end
       end  
    end 

end 

//hour counter 
wire hour1; 
assign hour1 = ((Ehour & edit) | (~(edit) & sec));
always @ (posedge(hour1) , posedge(rst) )   // trig of reset event handeler 
begin
    if (rst == 1'b1) begin // resetting counter
        Hhour  <= 5'b0; 
    end
   // else begin
   // Hhour <= Hhour + 5'b1 ; 
    else begin
      if (edit == 1'b1 && Ehour == 1'b1) begin
             if (Hhour  == 5'd23) begin
              Hhour  <= 5'b0; end 
              else begin 
              Hhour <= Hhour + 5'b1 ;
              end
       end   
       else begin
         if (Hhour  == 5'd23 && Hmin  == 6'd59 && Hsec  == 6'd59) begin
           Hhour  <= 5'b0; end 
           else begin
           if (Hmin == 6'd59 && Hsec  == 6'd59) begin Hhour <= Hhour + 5'b1 ; end
           end
       end  
    end 

end 

//day counter 
wire day1; 
assign day1 = ((Eday & edit) | (~(edit) & sec));
always @ (posedge(day1) , posedge(rst) )   // trig of reset event handeler 
begin
    if (rst == 1'b1) begin // resetting counter
        Hday  <= 5'b0; 
    end
   // else begin
   // Hday <= Hday + 5'b1 ; 
    else begin
      if (edit == 1'b1 && Eday == 1'b1) begin
             if (Hday  == 5'd29) begin
              Hday  <= 5'b0; end 
              else begin 
              Hday <= Hday + 5'b1 ;
              end
       end   
       else begin
         if (Hday  == 5'd29 && Hhour  == 5'd23 && Hmin  == 6'd59 && Hsec  == 6'd59) begin
           Hday  <= 5'b0; end 
           else begin
          if (Hhour == 5'd23 && Hmin  == 6'd59 && Hsec  == 6'd59) begin  Hday <= Hday + 5'b1 ; end
           end
       end  
    end 

end 

//months counter 
wire mon1; 
assign mon1 = ((Emonths & edit) | (~(edit) & sec));
always @ (posedge(mon1) , posedge(rst) )   // trig of reset event handeler 
begin
    if (rst == 1'b1) begin // resetting counter
        Hmon  <= 4'b0; 
    end
   // else begin
   // Hmon <= Hmon + 4'b1 ; 
    else begin
      if (edit == 1'b1 && Emonths == 1'b1) begin
             if (Hmon  == 4'd12) begin
              Hmon  <= 4'b0; end 
              else begin 
              Hmon <= Hmon + 4'b1 ;
              end
       end   
       else begin
         if (Hmon  == 4'd12 && Hday  == 5'd29 && Hhour  == 5'd23 && Hmin  == 6'd59 && Hsec  == 6'd59) begin
           Hmon  <= 4'b0; end 
           else begin
           if (Hday == 5'd29 && Hhour  == 5'd23 && Hmin  == 6'd59 && Hsec  == 6'd59) begin  Hmon <= Hmon + 4'b1 ; end
           end
       end  
    end 

end 

endmodule
