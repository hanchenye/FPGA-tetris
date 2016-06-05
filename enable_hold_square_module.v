module enable_hold_square_module
( clk, rst_n, col_addr_sig, row_addr_sig, hold_square,
  enable_hold_square
);
input clk;
input rst_n;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
input [15:0] hold_square;
output enable_hold_square;

/**************************************************/

reg [15:0] enable_hold_square_h;
reg [15:0] enable_hold_square_v;
reg [15:0] enable_hold_square_r;

/**************************************************/

generate
  genvar i;
  for( i = 0; i <= 15; i = i + 1)
    begin: iloop
      always @ ( posedge clk or negedge rst_n )
        begin
          if ( !rst_n )
            enable_hold_square_h[i] <= 1'b0;
          else if( hold_square[i] == 1'b1 )
            begin 
              if( col_addr_sig == 11'd191 + ( i % 11'd04 ) * 20 )  
                enable_hold_square_h[i] <= 1'b1; 
              else if( col_addr_sig == 11'd210 + ( i % 11'd04 ) * 20 )
                enable_hold_square_h[i] <= 1'b0; 
              else 
                enable_hold_square_h[i] <= enable_hold_square_h[i];
            end
          else 
            enable_hold_square_h[i] <= enable_hold_square_h[i];         
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
            enable_hold_square_v[j] <= 1'b0;
          else if( hold_square[j] == 1'b1 )
            begin
              if( row_addr_sig == 11'd161 + ( j / 11'd04 ) * 11'd20)
                enable_hold_square_v[j] <= 1'b1;
              else if( row_addr_sig == 11'd180 + ( j / 11'd04 ) * 11'd20 )
                enable_hold_square_v[j] <= 1'b0; 
              else 
                enable_hold_square_v[j] <= enable_hold_square_v[j];
            end
          else 
            enable_hold_square_v[j] <= enable_hold_square_v[j];
        end
    end
endgenerate

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      enable_hold_square_r <= 16'd0;
    else 
      enable_hold_square_r <= enable_hold_square_h & enable_hold_square_v;
  end
  
/**************************************************/

assign enable_hold_square = | enable_hold_square_r;   

/**************************************************/    
               
endmodule 