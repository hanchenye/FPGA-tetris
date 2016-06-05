module game_process_module
( clk, rst_n, game_over, 
  ingame_sig
);
input clk;
input rst_n;
input game_over;
output ingame_sig;

/**************************************************/

parameter in_game = 1'b1, out_game = 1'b0;

/**************************************************/

reg game_current_process;
reg game_next_process;
reg ingame_sig_r;

/**************************************************/

always @ ( posedge clk or negedge rst_n )
begin
  if( !rst_n )
     game_current_process <= in_game;
  else 
     game_current_process <= game_next_process;
end
  
always @ ( game_current_process or game_over )
begin
  case( game_current_process )
    in_game:
    begin
      ingame_sig_r = 1;
      if( game_over )
        game_next_process = out_game;
      else 
        game_next_process = in_game;
    end
    out_game:
    begin
      ingame_sig_r = 0;
      game_next_process = out_game;
    end
  endcase
end

/**************************************************/

assign ingame_sig = ingame_sig_r;

/**************************************************/

endmodule
 

   
   