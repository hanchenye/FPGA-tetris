module enable_fixed_square_module
( clk, rst_n, col_addr_sig, row_addr_sig, fixed_square_map, 
  enable_fixed_square
);
input clk;
input rst_n;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
input [359:0] fixed_square_map;
output enable_fixed_square;

/**************************************************/

reg [359:0] enable_fixed_square_h;
reg [359:0] enable_fixed_square_v;
wire [359:0] enable_fixed_square_360;
wire [13:0] enable_fixed_square_14;
wire enable_fixed_square_w;
reg enable_fixed_square_r;

/**************************************************/

generate
  genvar i;
  genvar j;
  for(i = 0; i <= 13; i = i + 1)
    begin: iloop
      for(j = 0; j <= 9;  j = j + 1)
        begin: jloop
          always @ ( posedge clk or negedge rst_n )
            begin
              if( !rst_n )
                enable_fixed_square_h[5 + 20 * i + j] <= 1'b0;
              else if( fixed_square_map[5 + 20 * i + j] == 1'b1 )
                begin
                  if( col_addr_sig == 311 + j * 20)
                    enable_fixed_square_h[5 + 20 * i + j] <= 1'b1;
                  else if( col_addr_sig == 330 + j * 20)
                    enable_fixed_square_h[5 + 20 * i + j] <= 1'b0;
                  else 
                    enable_fixed_square_h[5 + 20 * i + j] <= enable_fixed_square_h[5 + 20 * i + j];
                end
              else 
                enable_fixed_square_h[5 + 20 * i + j] <= enable_fixed_square_h[5 + 20 * i + j];
            end
        end
	  end
endgenerate

/**************************************************/

generate
  genvar m;
  genvar n;
  for(m = 0; m <= 13; m = m + 1)
    begin: mloop
      for(n = 0; n <= 9; n = n + 1)
        begin: nloop
          always @ ( posedge clk or negedge rst_n )
            begin
              if( !rst_n )
                 enable_fixed_square_v[5 + 20 * m + n] <= 1'b0;
              else if( fixed_square_map[5 + 20 * m + n] == 1'b1 )
                 begin
                   if( row_addr_sig == 41 + 20 * m)
                      enable_fixed_square_v[5 + 20 * m + n] <= 1'b1;
                   else if( row_addr_sig == 60 + 20 * m)
                      enable_fixed_square_v[5 + 20 * m + n] <= 1'b0;
                   else 
                      enable_fixed_square_v[5 + 20 * m + n] <= enable_fixed_square_v[5 + 20 * m + n];
                 end
              else 
                 enable_fixed_square_v[5 + 20 * m + n] <= enable_fixed_square_v[5 + 20 * m + n];
            end  
        end
    end
endgenerate  

/**************************************************/

generate
  genvar x;
  genvar y;
  for(x = 0; x <= 13; x = x + 1)
    begin: xloop
      assign enable_fixed_square_360[(4 + x * 20):(x * 20)] = 5'b00000;
      assign enable_fixed_square_360[(19 + x * 20):(15 + x * 20)] = 5'b00000;
      assign enable_fixed_square_14[x] = | enable_fixed_square_360[(5 + 20 * x + 9):(5 + 20 * x)];
      for(y = 0; y <= 9; y = y + 1)
        begin: yloop
          assign enable_fixed_square_360[5 + 20 * x + y] = enable_fixed_square_v[5 + 20 * x + y] && enable_fixed_square_h[5 + 20 * x + y];
        end
    end
endgenerate

assign enable_fixed_square_360[359:280] = 80'd0;
assign enable_fixed_square_w = | enable_fixed_square_14[13:0];

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
       enable_fixed_square_r <= 1'b0;
    else 
       enable_fixed_square_r <= enable_fixed_square_w;
  end      
  
/**************************************************/
 
assign enable_fixed_square = enable_fixed_square_r;

/**************************************************/

endmodule



