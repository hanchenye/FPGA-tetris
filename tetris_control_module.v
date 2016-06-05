module tetris_control_module 
( clk, rst_n, move_right, move_left, rotate_r, change, 
  moving_square_h, moving_square_v, moving_square, hold_square, 
  fixed_square_map, cur_score_bin, load_next_square, ingame_sig, game_over
); 
input clk;
input rst_n;
input move_right;
input move_left;
input rotate_r;
input change;
input ingame_sig;
output [10:0] moving_square_h;
output [10:0] moving_square_v;
output [15:0] moving_square;
output [15:0] hold_square;
output [299:0] fixed_square_map;
output load_next_square;
output [7:0] cur_score_bin;
output game_over;

/**************************************************/

parameter T1S = 26'd24_999_999;  

/**************************************************/

reg [10:0] moving_square_h_r;
reg [10:0] moving_square_v_r;
reg [15:0] moving_square_r;
reg [8:0] moving_square_loc;
reg [15:0] hold_square_r;
reg [299:0] fixed_square_map_r;
wire move_down_en;
wire move_right_en;
wire move_left_en;
wire rotate_en;
wire change_en;
wire fall_down; 
reg [15:0] rotate_test;
reg [25:0] count_down;
wire [13:0] sub_line;
wire sub_line_total;
reg [2:0] next_square_type;
reg rotate_r_dly;
reg fall_down_dly;
reg change_dly;
reg load_next_square_r;
reg game_over_r;
wire [15:0] move_down_en_w;
wire [15:0] move_right_en_w;
wire [15:0] move_left_en_w;
wire [15:0] rotate_en_w;
wire [15:0] change_en_w;
reg [7:0] cur_sub_line;

/**************************************************/
//控制1s下落一?
always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      count_down <= 26'd0;
    else if( count_down == T1S )
      count_down <= 26'd0;
    else if( ingame_sig )
      count_down <= count_down + 1'b1;
  end

assign fall_down = ( count_down == T1S ) && ( move_down_en );

/**************************************************/ 
//判断下落的方块是否能下移

generate
  genvar i;
  for(i = 0; i <= 15; i = i + 1)
    begin: iloop
      assign move_down_en_w[i] = moving_square_r[i] && fixed_square_map_r[moving_square_loc + i % 4 + i / 4 * 20 + 20];
    end
endgenerate

assign move_down_en = ~ (| move_down_en_w);

/**************************************************/ 
//判断下落的方块是否能右移

generate
  genvar j;
  for(j = 0; j <= 15; j = j + 1)
    begin: jloop
      assign move_right_en_w[j] = moving_square_r[j] && fixed_square_map_r[moving_square_loc + j % 4 + j / 4 * 20 + 1];
    end
endgenerate

assign move_right_en = ~(| move_right_en_w);

/**************************************************/
//判断下落的方块是否能左移

generate
  genvar x;
  for(x = 0; x <= 15; x = x + 1)
    begin: xloop
      assign move_left_en_w[x] = moving_square_r[x] && fixed_square_map_r[moving_square_loc + x % 4 + x / 4 * 20 - 1];
    end
endgenerate

assign move_left_en = ~(| move_left_en_w);

/**************************************************/
//判断下落的方块是否能和存储区的方块互?

generate
  genvar m;
  for(m = 0; m <= 15; m = m + 1)
    begin: mloop
      assign change_en_w[m] = hold_square_r[m] && fixed_square_map_r[moving_square_loc + m % 4 + m / 4 * 20];
    end
endgenerate

assign change_en = ~(| change_en_w);

/**************************************************/
//判断下落的方块是否能向右旋转

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
      rotate_test <= 16'b0000_0111_0010_0000;
    else if( rotate_r == 1'b1 )
      begin
        rotate_test[0] <= rotate_test[12];
        rotate_test[1] <= rotate_test[8];
        rotate_test[2] <= rotate_test[4];
        rotate_test[3] <= rotate_test[0];
        rotate_test[4] <= rotate_test[13];
        rotate_test[5] <= rotate_test[9];
        rotate_test[6] <= rotate_test[5];
        rotate_test[7] <= rotate_test[1];
        rotate_test[8] <= rotate_test[14];
        rotate_test[9] <= rotate_test[10];
        rotate_test[10] <= rotate_test[6];
        rotate_test[11] <= rotate_test[2];
        rotate_test[12] <= rotate_test[15];
        rotate_test[13] <= rotate_test[11];
        rotate_test[14] <= rotate_test[7];
        rotate_test[15] <= rotate_test[3];
      end
  end

generate
  genvar y;
  for(y = 0; y <= 15; y = y + 1)
    begin: yloop
      assign rotate_en_w[y] = rotate_test[y] && fixed_square_map_r[moving_square_loc + y % 4 + y / 4 * 20];
    end
endgenerate

assign rotate_en = ~(| rotate_en_w);

/**************************************************/
//判断是否发生成功碰撞

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
       fall_down_dly <= 1'b0;
    else 
       fall_down_dly <= fall_down;
  end
  
always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n )
       load_next_square_r <= 1'b0;
    else 
       load_next_square_r <= fall_down_dly && ( ~move_down_en );
  end

/**************************************************/
//向右旋转操作、加载新方块、交换存储区方块的控?

always @(posedge clk or negedge rst_n ) 
  begin
    if ( !rst_n ) 
      change_dly <= 1'b0;
    else
      change_dly <= change;
  end

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      rotate_r_dly <= 1'b0;
    else 
      rotate_r_dly <= rotate_r;
  end

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
     begin
        moving_square_r <= 16'b0000_0111_0010_0000;
        hold_square_r <= 16'b0000_0110_0110_0000;
    end
    else if( rotate_r_dly && rotate_en )
      begin 
        moving_square_r[0] <= moving_square_r[12];
        moving_square_r[1] <= moving_square_r[8];
        moving_square_r[2] <= moving_square_r[4];
        moving_square_r[3] <= moving_square_r[0];
        moving_square_r[4] <= moving_square_r[13];
        moving_square_r[5] <= moving_square_r[9];
        moving_square_r[6] <= moving_square_r[5];
        moving_square_r[7] <= moving_square_r[1];
        moving_square_r[8] <= moving_square_r[14];
        moving_square_r[9] <= moving_square_r[10];
        moving_square_r[10] <= moving_square_r[6];
        moving_square_r[11] <= moving_square_r[2];
        moving_square_r[12] <= moving_square_r[15];
        moving_square_r[13] <= moving_square_r[11];
        moving_square_r[14] <= moving_square_r[7];
        moving_square_r[15] <= moving_square_r[3];
      end
    else if( change_dly && change_en )
      begin
        moving_square_r <= hold_square_r;
        hold_square_r <= moving_square_r;
      end
    else if( load_next_square_r )
      begin
        case( next_square_type )
          3'b000: moving_square_r <= 16'b0000_0111_0010_0000;
          3'b001: moving_square_r <= 16'b0000_0110_0110_0000;
          3'b010: moving_square_r <= 16'b0000_0000_1111_0000;
          3'b011: moving_square_r <= 16'b0000_0011_0110_0000;
          3'b100: moving_square_r <= 16'b0000_0110_0011_0000;
          3'b101: moving_square_r <= 16'b0000_0111_0100_0000;
          3'b110: moving_square_r <= 16'b0000_1110_0010_0000;
          default: moving_square_r <= 16'b0000_0110_0110_0000;
        endcase
      end
  end

/**************************************************/
//产生下一个方块的种类

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      next_square_type <= 3'd0;
    else if( load_next_square_r )
      next_square_type <= next_square_type + 1'b1;
  end

/**************************************************/
//更新下落的方块的标志位信息和显示信息
 
always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      moving_square_loc <= 9'd8;
    else if( load_next_square_r )
      moving_square_loc <= 9'd8;
    else if( move_right && move_right_en)
      moving_square_loc <= moving_square_loc + 1'b1;
    else if( move_left && move_left_en )  
      moving_square_loc <= moving_square_loc - 1'b1;
    else if( fall_down )
      moving_square_loc <= moving_square_loc + 9'd20;
  end                      

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
      moving_square_h_r <= 11'd370;
    else if( load_next_square_r )
      moving_square_h_r <= 11'd370;
    else if( move_right && move_right_en )
      moving_square_h_r <= moving_square_h_r + 11'd20;
    else if( move_left && move_left_en )
      moving_square_h_r <= moving_square_h_r - 11'd20;  
  end

always @ ( posedge clk or negedge rst_n )
  begin 
    if( !rst_n )
       moving_square_v_r <= 11'd40;
    else if( load_next_square_r )
       moving_square_v_r <= 11'd40;
    else if( fall_down )
       moving_square_v_r <= moving_square_v_r + 11'd20;
  end

/**************************************************/
//检查是否有某行已满需要消�

generate
  genvar p;
  for(p = 0; p <= 13; p = p + 1)
    begin: ploop
      assign sub_line[p] = & fixed_square_map_r[(14 + 20 * p):(5 + 20 * p)];
    end
endgenerate

assign sub_line_total = | sub_line[13:0];

/**************************************************/
//更新游戏区域内方块分布情况的信息

always @ ( posedge clk or negedge rst_n )
  begin
    if( !rst_n ) 
      begin
        fixed_square_map_r <= {300{1'b1}};
        fixed_square_map_r[14:5] <= 10'b0;
        fixed_square_map_r[34:25] <= 10'b0;
        fixed_square_map_r[54:45] <= 10'b0;
        fixed_square_map_r[74:65] <= 10'b0;
        fixed_square_map_r[94:85] <= 10'b0;
        fixed_square_map_r[114:105] <= 10'b0;
        fixed_square_map_r[134:125] <= 10'b0;
        fixed_square_map_r[154:145] <= 10'b0;
        fixed_square_map_r[174:165] <= 10'b0;
        fixed_square_map_r[194:185] <= 10'b0;
        fixed_square_map_r[214:205] <= 10'b0;
        fixed_square_map_r[234:225] <= 10'b0;
        fixed_square_map_r[254:245] <= 10'b0;
        fixed_square_map_r[274:265] <= 10'b0;
        cur_sub_line <= 0;
      end 
    else if( sub_line_total )
      begin 
        if( sub_line[0] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[34:25];
            fixed_square_map_r[54:45] <= fixed_square_map_r[54:45];
            fixed_square_map_r[74:65] <= fixed_square_map_r[74:65];
            fixed_square_map_r[94:85] <= fixed_square_map_r[94:85];
            fixed_square_map_r[114:105] <= fixed_square_map_r[114:105];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end
        if( sub_line[1] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[54:45];
            fixed_square_map_r[74:65] <= fixed_square_map_r[74:65];
            fixed_square_map_r[94:85] <= fixed_square_map_r[94:85];
            fixed_square_map_r[114:105] <= fixed_square_map_r[114:105];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end 
        if( sub_line[2] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[74:65];
            fixed_square_map_r[94:85] <= fixed_square_map_r[94:85];
            fixed_square_map_r[114:105] <= fixed_square_map_r[114:105];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end      
        if( sub_line[3] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[94:85];
            fixed_square_map_r[114:105] <= fixed_square_map_r[114:105];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end
        if( sub_line[4] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[114:105];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end
        if( sub_line[5] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[134:125];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end 
        if( sub_line[6] )
          begin
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[154:145];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end   
        if( sub_line[7] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[174:165];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end    
        if( sub_line[8] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[194:185];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end    
        if( sub_line[9] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[174:165];
            fixed_square_map_r[214:205] <= fixed_square_map_r[214:205];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end     
        if( sub_line[10] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[174:165];
            fixed_square_map_r[214:205] <= fixed_square_map_r[194:185];
            fixed_square_map_r[234:225] <= fixed_square_map_r[234:225];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end  
        if( sub_line[11] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[174:165];
            fixed_square_map_r[214:205] <= fixed_square_map_r[194:185];
            fixed_square_map_r[234:225] <= fixed_square_map_r[214:205];
            fixed_square_map_r[254:245] <= fixed_square_map_r[254:245];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end 
        if( sub_line[12] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[174:165];
            fixed_square_map_r[214:205] <= fixed_square_map_r[194:185];
            fixed_square_map_r[234:225] <= fixed_square_map_r[214:205];
            fixed_square_map_r[254:245] <= fixed_square_map_r[234:225];
            fixed_square_map_r[274:265] <= fixed_square_map_r[274:265];
            cur_sub_line <= cur_sub_line + 1;
          end 
        if( sub_line[13] )
          begin 
            fixed_square_map_r[14:5] <= 10'b0;
            fixed_square_map_r[34:25] <= fixed_square_map_r[14:5];
            fixed_square_map_r[54:45] <= fixed_square_map_r[34:25];
            fixed_square_map_r[74:65] <= fixed_square_map_r[54:45];
            fixed_square_map_r[94:85] <= fixed_square_map_r[74:65];
            fixed_square_map_r[114:105] <= fixed_square_map_r[94:85];
            fixed_square_map_r[134:125] <= fixed_square_map_r[114:105];
            fixed_square_map_r[154:145] <= fixed_square_map_r[134:125];
            fixed_square_map_r[174:165] <= fixed_square_map_r[154:145];
            fixed_square_map_r[194:185] <= fixed_square_map_r[174:165];
            fixed_square_map_r[214:205] <= fixed_square_map_r[194:185];
            fixed_square_map_r[234:225] <= fixed_square_map_r[214:205];
            fixed_square_map_r[254:245] <= fixed_square_map_r[234:225];
            fixed_square_map_r[274:265] <= fixed_square_map_r[254:245];
            cur_sub_line <= cur_sub_line + 1;
          end
      end
    else if( load_next_square_r )
      begin
        fixed_square_map_r[moving_square_loc] <= moving_square_r[0] || fixed_square_map_r[moving_square_loc];
        fixed_square_map_r[moving_square_loc + 8'd1] <= moving_square_r[1] || fixed_square_map_r[moving_square_loc + 8'd1];
        fixed_square_map_r[moving_square_loc + 8'd2] <= moving_square_r[2] || fixed_square_map_r[moving_square_loc + 8'd2];
        fixed_square_map_r[moving_square_loc + 8'd3] <= moving_square_r[3] || fixed_square_map_r[moving_square_loc + 8'd3];        
        fixed_square_map_r[moving_square_loc + 8'd20] <= moving_square_r[4] || fixed_square_map_r[moving_square_loc + 8'd20];
        fixed_square_map_r[moving_square_loc + 8'd21] <= moving_square_r[5] || fixed_square_map_r[moving_square_loc + 8'd21];
        fixed_square_map_r[moving_square_loc + 8'd22] <= moving_square_r[6] || fixed_square_map_r[moving_square_loc + 8'd22];
        fixed_square_map_r[moving_square_loc + 8'd23] <= moving_square_r[7] || fixed_square_map_r[moving_square_loc + 8'd23];    
        fixed_square_map_r[moving_square_loc + 8'd40] <= moving_square_r[8] || fixed_square_map_r[moving_square_loc + 8'd40];
        fixed_square_map_r[moving_square_loc + 8'd41] <= moving_square_r[9] || fixed_square_map_r[moving_square_loc + 8'd41];
        fixed_square_map_r[moving_square_loc + 8'd42] <= moving_square_r[10] || fixed_square_map_r[moving_square_loc + 8'd42];
        fixed_square_map_r[moving_square_loc + 8'd43] <= moving_square_r[11] || fixed_square_map_r[moving_square_loc + 8'd43];        
        fixed_square_map_r[moving_square_loc + 8'd60] <= moving_square_r[12] || fixed_square_map_r[moving_square_loc + 8'd60];
        fixed_square_map_r[moving_square_loc + 8'd61] <= moving_square_r[13] || fixed_square_map_r[moving_square_loc + 8'd61];
        fixed_square_map_r[moving_square_loc + 8'd62] <= moving_square_r[14] || fixed_square_map_r[moving_square_loc + 8'd62];
        fixed_square_map_r[moving_square_loc + 8'd63] <= moving_square_r[15] || fixed_square_map_r[moving_square_loc + 8'd63];
        cur_sub_line <= cur_sub_line;
      end
  end 

/**************************************************/
//判断游戏是否结束

always @ ( posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      game_over_r <= 0;
    else if ( moving_square_loc == 9'd8 && (~move_down_en))
      game_over_r <= 1;
  end

/**************************************************/  

assign moving_square_h = moving_square_h_r;
assign moving_square_v = moving_square_v_r;
assign fixed_square_map = fixed_square_map_r;
assign load_next_square = load_next_square_r;
assign game_over = game_over_r;
assign moving_square = moving_square_r;
assign hold_square = hold_square_r;
assign cur_score_bin = cur_sub_line;
 
/**************************************************/

endmodule
