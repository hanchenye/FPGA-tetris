module enable_next_square_module
( clk, rst_n, col_addr_sig, row_addr_sig, load_next_square, 
  enable_next_square
);
input clk;
input rst_n;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
input load_next_square;
output enable_next_square;

/**************************************************/

reg [2:0] square_type;  
reg [15:0] enable_square;
reg [15:0] enable_next_square_h;
reg [15:0] enable_next_square_v;
reg [15:0] enable_next_square_r;

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      square_type <= 3'd0;
    else if( load_next_square )
      square_type <= square_type + 1'b1;
    else 
      square_type <= square_type;
  end
  
/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      enable_square <= 16'b0000_0111_0010_0010;
    else  
      begin
        case(square_type)
          3'b000: enable_square <= 16'b0000_0111_0010_0000;
          3'b001: enable_square <= 16'b0000_0110_0110_0000;
          3'b010: enable_square <= 16'b0000_0000_1111_0000;
          3'b011: enable_square <= 16'b0000_0011_0110_0000;
          3'b100: enable_square <= 16'b0000_0110_0011_0000;
          3'b101: enable_square <= 16'b0000_0111_0100_0000;
          3'b110: enable_square <= 16'b0000_1110_0010_0000;
          default: enable_square <= 16'b0000_0110_0110_0000;
        endcase 
      end
  end
  
/**************************************************/

generate
  genvar i;
  for( i = 0; i <= 15; i = i + 1)
    begin: iloop
      always @ ( posedge clk or negedge rst_n )
        begin
          if ( !rst_n )
            enable_next_square_h[i] <= 1'b0;
          else if( enable_square[i] == 1'b1 )
            begin 
              if( col_addr_sig == 11'd191 + ( i % 11'd04 ) * 20 )  
                enable_next_square_h[i] <= 1'b1; 
              else if( col_addr_sig == 11'd210 + ( i % 11'd04 ) * 20 )
                enable_next_square_h[i] <= 1'b0; 
              else 
                enable_next_square_h[i] <= enable_next_square_h[i];
            end
          else 
            enable_next_square_h[i] <= enable_next_square_h[i];         
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
            enable_next_square_v[j] <= 1'b0;
          else if( enable_square[j] == 1'b1 )
            begin
              if( row_addr_sig == 11'd51 + ( j / 11'd04 ) * 11'd20)
                enable_next_square_v[j] <= 1'b1;
              else if( row_addr_sig == 11'd70 + ( j / 11'd04 ) * 11'd20 )
                enable_next_square_v[j] <= 1'b0; 
              else 
                enable_next_square_v[j] <= enable_next_square_v[j];
            end
          else 
            enable_next_square_v[j] <= enable_next_square_v[j];
        end
    end
endgenerate

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      enable_next_square_r <= 16'd0;
    else 
      enable_next_square_r <= enable_next_square_h & enable_next_square_v;
  end
  
/**************************************************/

assign enable_next_square = | enable_next_square_r;   

/**************************************************/    
               
endmodule 


