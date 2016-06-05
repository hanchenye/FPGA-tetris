module clk_gen_module
( clk_in, 
  clk_25MHz
);
input clk_in;
output clk_25MHz;

/**************************************************/

parameter N=4;

/**************************************************/

reg [1:0] cnt;
reg clk_25MHz;

/**************************************************/

always @(posedge clk_in) 
begin
  if(cnt == N/2-1)
    begin 
        clk_25MHz <= !clk_25MHz; 
        cnt <= 0; 
    end
  else
    cnt <= cnt + 1;
end

/**************************************************/

endmodule