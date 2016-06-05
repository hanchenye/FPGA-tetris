module game_sync_module
( clk, rst_n, 
  sync_ready_sig, col_addr_sig, row_addr_sig, 
  hsync_out, vsync_out, pic_addr
);
input clk;
input rst_n;
output sync_ready_sig;
output [10:0] col_addr_sig;
output [10:0] row_addr_sig;
output hsync_out;
output vsync_out;
output [18:0] pic_addr;

/**************************************************/

reg [18:0] cnt_h;
reg [18:0] cnt_v;
reg sync_ready_sig_r;
wire [18:0] pic_addr_w;
wire [18:0] col_addr_sig_w;
wire [18:0] row_addr_sig_w;

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      cnt_h <= 18'd0;
    else if( cnt_h == 18'd800 )
      cnt_h <= 18'd0;
    else cnt_h <= cnt_h + 1'b1;
  end

always @ ( posedge clk or negedge rst_n )
  begin  
    if( !rst_n )
      cnt_v <= 18'd0;
    else if( cnt_v == 18'd525 )
      cnt_v <= 18'd0;
    else if( cnt_h == 18'd800 )
      cnt_v <= cnt_v + 1'b1;
  end 
  
/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      sync_ready_sig_r <= 1'b0;
    else if( cnt_h >= 144 && cnt_h < 784 && cnt_v >= 35 && cnt_v < 515 )
      sync_ready_sig_r <= 1'b1;
    else sync_ready_sig_r <= 1'b0;
  end
  
/**************************************************/

assign pic_addr_w = col_addr_sig_w + row_addr_sig_w * 640;
assign col_addr_sig_w = sync_ready_sig_r ? ( cnt_h - 18'd144 ) : 18'd0;
assign row_addr_sig_w = sync_ready_sig_r ? ( cnt_v - 18'd35 ) : 18'd0;

/**************************************************/

assign sync_ready_sig = sync_ready_sig_r;
assign col_addr_sig = col_addr_sig_w[10:0];
assign row_addr_sig = row_addr_sig_w[10:0];
assign hsync_out = ( cnt_h <= 11'd96 ) ? 1'b0 : 1'b1;
assign vsync_out = ( cnt_v <= 11'd2 ) ? 1'b0 : 1'b1;
assign pic_addr = pic_addr_w;

/**************************************************/

endmodule
        
