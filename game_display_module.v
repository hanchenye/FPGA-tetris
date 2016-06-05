module game_display_module
( clk, rst_n, sync_ready_sig, ingame_sig,
  enable_border, enable_moving_square, enable_fixed_square, enable_next_square, enable_hold_square,
  pic_over_data, pic_next_data, pic_hold_data, pic_score_data, pic_num_data,
  red_out, green_out, blue_out
);
input clk;
input rst_n;
input sync_ready_sig;
input ingame_sig;
input enable_border;
input enable_moving_square;
input enable_fixed_square;
input enable_next_square;
input enable_hold_square;
input pic_over_data;
input pic_next_data;
input pic_hold_data;
input pic_score_data;
input pic_num_data;
output red_out;
output green_out;
output blue_out;

/**************************************************/		  

reg bg_red;
reg bg_green;
reg bg_blue;
reg red_out_r;
reg green_out_r;
reg blue_out_r;

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      begin 
        bg_red   <= pic_next_data | pic_hold_data | pic_score_data | enable_border | pic_num_data | enable_next_square | enable_hold_square;
        bg_green <= pic_next_data | pic_hold_data | pic_score_data | enable_border | pic_num_data | enable_next_square | enable_hold_square | enable_fixed_square;
        bg_blue  <= pic_next_data | pic_hold_data | pic_score_data | enable_border | enable_fixed_square;
      end
    else if( sync_ready_sig )
      begin
        bg_red   <= pic_next_data | pic_hold_data | pic_score_data | enable_border | pic_num_data | enable_next_square | enable_hold_square;
        bg_green <= pic_next_data | pic_hold_data | pic_score_data | enable_border | pic_num_data | enable_next_square | enable_hold_square | enable_fixed_square;
        bg_blue  <= pic_next_data | pic_hold_data | pic_score_data | enable_border | enable_fixed_square;
      end
  end

/**************************************************/

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      begin 
        red_out_r   <= bg_red   | enable_moving_square;
/*        green_out_r <= bg_green | enable_moving_square;
        blue_out_r  <= bg_blue;
*/      end
	 else if( ingame_sig == 1 )
	    begin 
        red_out_r   <= bg_red   | enable_moving_square;
        green_out_r <= bg_green | enable_moving_square;
        blue_out_r  <= bg_blue;
      end
    else if( ingame_sig == 0 )
      begin
        red_out_r   <= bg_red   | pic_over_data;
        green_out_r <= bg_green | enable_moving_square;
        blue_out_r  <= bg_blue  | enable_moving_square;
      end
    else 
      begin
        red_out_r   <= bg_red   | enable_moving_square;
        green_out_r <= bg_green | enable_moving_square;
        blue_out_r  <= bg_blue;
      end  
  end 
 
/**************************************************/

assign red_out = red_out_r;
assign green_out = green_out_r;
assign blue_out = blue_out_r;

/**************************************************/

endmodule