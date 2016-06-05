# FPGA Tetris Game

---
### 一、项目简介
本项目基于复旦微电子 JFM4VSX55 FPGA DEMO 板开发，使用 Verilog HDL 在 Xilinx ISE 14.7 开发环境下编写，实现了俄罗斯方块的功能。其具有以下特点。

- 使用标准 VGA 接口输出，通过外接显示器显示游戏画面。
- 输出的 VGA 信号分辨率为 640 x 480，刷新频率 60Hz，显示带宽 25MHz。
- 使用 DEMO 板上提供的按键进行操作，分别提供了重置游戏、方块左移、右移、向右旋转、置换存储区方块等功能。
- 可自动计分，并在显示器上显示当前分数。

---
### 二、关于俄罗斯方块

![1](http://img.blog.csdn.net/20160604193806192)

俄罗斯方块是由以上这几种四格骨牌构成，全部都由四个方块组成。开始时，一个随机的方块会从区域上方开始缓慢继续落下。落下期间，玩家可以以90度为单位旋转方块，以格子为单位左右移动方块。当方块下落到区域最下方或着落到其他方块上无法再向下移动时，就会固定在该处，然后一个新的随机的方块会出现在区域上方开始落下。当区域中某一横行（列）的格子全部由方块填满时，则该列会被消除并成为玩家的得分。当固定的方块堆到区域最顶端而无法消除层数时，游戏就会结束。

在本项目中，七种俄罗斯方块都由 4 x 4 的像素块构成，以便于进行统一化控制，具体如下图所示。

![2](http://img.blog.csdn.net/20160604220943830)

本项目的特色是存在一个置换区，可以存储一个方块，如果玩家认为当前下落的方块难易放置，可以将当前下落的方块与置换区方块置换。下图为最终显示界面的设计原图，可以看到图中「 HOLD: 」标示后面的方块为当前置换区的方块。

![3](http://img.blog.csdn.net/20160606011614902)

---
### 三、快速开始
在 DEMO 板上提供的可自定义的五个按键，功能分别如下图所示。

![4](http://img.blog.csdn.net/20160604221034346)

将程序烧入 DEMO 板，与显示器连接后，直接按 rst 键即可开始游戏，按 left 键将方块左移，按 right 键将方块右移，按 rotate 键将方块向右旋转， 按 hold 键将当前方块与存储区方块置换。当一行已满时会自动消除，同时当前分数加一。当整个游戏面板被填满时，游戏自动结束，同时提示 GAME OVER。此时按 rst 键可重置游戏，清空游戏面板重新开始。

部分游戏画面如下图所示。完整演示视频见附件。

![5](http://img.blog.csdn.net/20160606020752442)

---
### 四、项目架构
本项目采用模块化的设计，各个模块之间关系如下图所示。

![6](http://img.blog.csdn.net/20160604220454375)

下面我将对其中每一个的功能和特点进行简单介绍。

#### 1. tetris\_game
`tetris_game`为顶层模块，负责连接各个子模块。该模块的 input 和 output 直接与 FPGA 给出的接口相连，具体连接方法见 ucf 管脚约束文件`tetris_game.ucf`。

#### 2. tetris\_control\_module
`tetris_control_module`为处理俄罗斯方块游戏逻辑的核心模块，包括但不仅限于控制方块 1s 下降一格、判断是否能够左移右移旋转置换、判断是否需要消行、判断游戏是否结束、存储置换区方块、加载下一个方块、自动计分等功能。

#### 3. clk\_gen\_module
`clk_gen_module`对系统提供的 100MHz 时钟进行分频，得到 25MHz 的时钟信号，为整个程序提供时钟。25MHz 是分辨率 640 x 480 ，场频 60Hz 的 VGA 信号的标准频率。

#### 4. debouncer\_module
`debouncer_module`对按键操作进行防抖处理，为其他模块给出按键信号。

#### 5. enable\_xx\_module
`enable_border_module`、`enable_fixed_square_module`、`enable_moving_square_module`、`enable_next_square_module`、`enable_hold_square_module`五个模块分别为游戏面板边框、已经落下固定的方块、正在下落的方块、下一个方块、存储区方块的 VGA 显示提供 RGB 信号，均为 1bit 宽。

#### 6. pic\_xx\_module 
`pic_next_module`、`pic_hold_module`、`pic_score_module`、`pic_over_module`、`pic_num_module`等模块均使用了 Xilinx 提供的 IP 核，从单端 ROM 中读取图片数据，分别负责显示「 NEXT: 」、「 HOLD: 」、「 SCORE: 」、「 GAME OVER ! 」字样和当前的分数。由于 Flash 存储空间的限制，无法进行全真彩的输出显示，所以这几个模块给出的信号宽度均为 1bit 。

#### 7. score\_control\_module
`score_control_module`对当前分数进行控制，每消去一行，当前分数增加一分，同时给出从 ROM 中读取数字图片的地址。0 - 9 十个数字图片都存储在一块 ROM 中，总共有三位数字显示，最高分数为 999 分。

#### 8. game\_process\_module
`game_process_module`对整个游戏的进程进行控制，对按键和游戏进度作出响应，给出`ingame_sig`信号，指示游戏的当前状态。

#### 9. game\_display\_module
`game_display_module`综合了 5、6 中多个模块给出的 RGB 信号，按照游戏进程对这些使能信号进行选择，给出用于 VGA 传输的三个 RGB 信号`red_out`、`green_out`、`blue_out`。

#### 10. game\_sync\_module
`game_sync_module`负责整个项目的时序控制，给出用于 VGA 传输的行同步信号`hsync_out`、列同步信号`vsync_out`。给出用于显示控制的行信号`row_addr_sig`、列信号`col_addr_sig`和显示就绪信号`sync_ready_sig`。

---
### 五、参考和致谢
1. 本项目的多个模块参考了以下几个页面：
- http://bbs.eetop.cn/thread-446226-1-1.html
- https://github.com/NigoroJr/fpga_tetris
- http://tinyvga.com/vga-timing/640x480@60Hz
2. 本页面「关于俄罗斯方块」一节引用了 Tetris 词条的维基百科页面：
- https://en.wikipedia.org/wiki/Tetris
3. 特别致谢张秉异同学在项目过程中对我的帮助。
4. 特别致谢俄罗斯方块大师杨浩然同学和他编写的网站：
- http://farter.tk

---
本页面编写于2016年6月4日。

