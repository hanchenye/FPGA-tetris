module enable_moving_square
( clk, rst_n, col_addr_sig, row_addr_sig, moving_square_h, moving_square_v, moving_square, 
  enable_moving_square 
);
input clk;
input rst_n;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
input [10:0] moving_square_h;
input [10:0] moving_square_v;
input [15:0] moving_square;
output enable_moving_square;

/**************************************************/

reg [15:0] enable_moving_square_h;
reg [15:0] enable_moving_square_v;
reg [15:0] enable_moving_square_r;

/**************************************************/

generate
  genvar i;
  for( i = 0; i <= 15; i = i + 1)
    begin: iloop
      always @ ( posedge clk or negedge rst_n )
        begin
          if ( !rst_n )
            enable_moving_square_h[i] <= 1'b0;
          else if ( moving_square[i] == 1'b1 )
            begin
              if ( col_addr_sig == moving_square_h + ( i % 4 ) * 11'd20 + 11'd2 )
                enable_moving_square_h[i] <= 1'b1;
              else if( col_addr_sig == moving_square_h + ( i % 4 ) * 11'd20 + 11'd21 )
                enable_moving_square_h[i] <= 1'b0;
              else 
                enable_moving_square_h[i] <= enable_moving_square_h[i]; 
            end
          else
            enable_moving_square_h[i] <= enable_moving_square_h[i];
        end
    end
endgenerate

/**************************************************/

generate
  genvar j;
  for( j = 0; j <= 15; j = j + 1)
    begin: jloop
      always @ ( posedge clk or negedge rst_n )
        begin
          if( !rst_n )
            enable_moving_square_v[j] <= 1'b0;
          else if( moving_square[j] == 1'b1 )
            begin
              if( row_addr_sig == moving_square_v + ( j / 11'd04 ) * 11'd20 + 11'd1)
                enable_moving_square_v[j] <= 1'b1;
              else if( row_addr_sig == moving_square_v + ( j / 11'd04 ) * 11'd20 + 11'd20 )
                enable_moving_square_v[j] <= 1'b0; 
              else 
                enable_moving_square_v[j] <= enable_moving_square_v[j];
            end
          else 
            enable_moving_square_v[j] <= enable_moving_square_v[j];
        end
    end
endgenerate

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      enable_moving_square_r <= 16'b0000_0000_0000_0000;
    else 
      enable_moving_square_r <= enable_moving_square_h & enable_moving_square_v;
  end
  
/**************************************************/

assign enable_moving_square = | enable_moving_square_r;

/**************************************************/

endmodule


