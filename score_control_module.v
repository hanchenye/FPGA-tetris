module score_control_module
( clk, rst_n, cur_score_bin, col_addr_sig, row_addr_sig,
  pic_num_addr
);
input clk;
input rst_n;
input [7:0] cur_score_bin;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
output [13:0] pic_num_addr;

/**************************************************/

reg [13:0] pic_num_addr_r;
reg [3:0] hunds;
reg [3:0] tens;
reg [3:0] ones;
integer i;

/**************************************************/

always @(cur_score_bin)
begin
  hunds = 4'd0;
  tens = 4'd0;
  ones = 4'd0;

  for (i = 7; i >= 0; i = i - 1)
  begin
    if (hunds >= 5)
      hunds = hunds + 3;
    if (tens >= 5)
      tens = tens + 3;
    if (ones >= 5)
      ones = ones + 3;

    hunds = hunds << 1;
    hunds[0] = tens[3];
    tens = tens << 1;
    tens[0] = ones[3];
    ones = ones << 1;
    ones[0] = cur_score_bin[i];
  end
end

/**************************************************/

always @(posedge clk or negedge rst_n) 
  begin
    if (!rst_n) 
      pic_num_addr_r <= 0;
	 else if ( row_addr_sig >= 283 && row_addr_sig < 323 )
	   begin
		  if (col_addr_sig >= 195 && col_addr_sig < 220) 
          pic_num_addr_r <= (row_addr_sig - 283) * 250 + hunds * 25 + col_addr_sig - 195;
        if (col_addr_sig >= 220 && col_addr_sig < 245) 
          pic_num_addr_r <= (row_addr_sig - 283) * 250 + tens * 25 + col_addr_sig - 220;
        if (col_addr_sig >= 245 && col_addr_sig < 270) 
          pic_num_addr_r <= (row_addr_sig - 283) * 250 + ones * 25 + col_addr_sig - 245;
      end 
  end

/**************************************************/

assign pic_num_addr = pic_num_addr_r;

/**************************************************/

endmodule