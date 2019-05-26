module check_temp (sh,alarm,data_out);  
  input [7:0]data_out;
  output reg alarm;
  output reg sh;

// check the temperature 
  always @ (data_out)
  begin 
              if (data_out>=250)
                begin
                 alarm=0;    //alarm for high temp
                 sh=1;
               end
              else if (data_out>=200)
                begin
                  sh =0;    //shutdown
                  alarm=1;
                end
              else
                begin
                  alarm=0;
                  sh=0;
                end
  end
endmodule
