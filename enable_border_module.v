module enable_border_module
( clk, rst_n, col_addr_sig, row_addr_sig, 
  enable_border
);
input clk;
input rst_n;
input [10:0] col_addr_sig;
input [10:0] row_addr_sig;
output enable_border;

/**************************************************/

parameter h_start = 11'd300;
parameter v_start = 11'd50;
parameter border_width = 11'd10;

/**************************************************/

reg out_h;
reg out_v;
reg in_h;
reg in_v;
reg enable_border_r;

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      out_h <= 1'b0;
    else if( col_addr_sig == h_start ) 
      out_h <= 1'b1;
    else if( col_addr_sig == h_start + 11'd221 )
      out_h <= 1'b0;
    else 
      out_h <= out_h;
  end
  
always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      out_v <= 1'b0;
    else if( row_addr_sig == v_start )
      out_v <= 1'b1;
    else if( row_addr_sig == v_start + 11'd281 ) 
      out_v <= 1'b0;
    else 
      out_v <= out_v;
  end
  
/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      in_h <= 1'b0;
    else if( col_addr_sig == h_start + border_width ) 
      in_h <= 1'b1;
    else if( col_addr_sig == h_start + 11'd211 )
      in_h <= 1'b0;
    else 
      in_h <= in_h;
  end
  
always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      in_v <= 1'b0;
    else if( row_addr_sig == v_start + border_width )
      in_v <= 1'b1;
    else if( row_addr_sig == v_start + 11'd271 ) 
      in_v <= 1'b0;
    else 
      in_v <= in_v;
  end
  
/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      enable_border_r <= 1'b0;
    else 
      enable_border_r <= ( out_h && out_v ) && ( !( in_h && in_v ) );
  end
  
/**************************************************/

assign enable_border = enable_border_r;

/**************************************************/

endmodule

