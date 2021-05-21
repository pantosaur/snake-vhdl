--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.snake_package.all;

entity game_top is
    port(
    rst : in std_logic;
    clk : in std_logic;
    ram_we : out std_logic;
    ram_addr : out std_logic_vector(8 downto 0);
    ram_data : out std_logic_vector(7 downto 0);
    user_control: in std_logic_vector(3 downto 0)
    );
end game_top;

architecture Behavioral of game_top is

component speed_timer is
    port(
        clk : in std_logic;
        rst : in std_logic;
        cnt_out : out std_logic_vector(24 downto 0)
    );
end component;
component snk_pos is
    port(
        clk : in std_logic;
        rst : in std_logic;
        control : in std_logic_vector(1 downto 0);
        snake_array : out snake;
        snake_size : out std_logic_vector(5 downto 0);
        ready : out std_logic;
        valid : in std_logic;
        snake_size_inc : in std_logic;
        snake_reset : in std_logic
        );
end component;
component apple_pos is
Port ( 
    clk : in std_logic;
    rst : in std_logic;
    pos : out std_logic_vector(5 downto 0);
    ready : out std_logic;
    valid : in std_logic;
    snake_array : in snake;
    snake_size : in std_logic_vector(5 downto 0)
);
end component;

component world_gen is
    port(
        rst : in std_logic;
        clk : in std_logic;
        ram_we : out std_logic;
        ram_addr : out std_logic_vector(8 downto 0);
        ram_data : out std_logic_vector(7 downto 0);
        game_state : in std_logic_vector(1 downto 0);
        snake_array : in snake;
        snake_size : in std_logic_vector(5 downto 0);
        apple_pos : in std_logic_vector(5 downto 0)
    );
end component;

component game_fsm is
port(
    rst : in std_logic;
    clk : in std_logic;
    go : in std_logic;
    control_in : in std_logic_vector(3 downto 0);
    control_out : out std_logic_vector(1 downto 0);
    snake_reset : out std_logic;
    snake_size_inc : out std_logic;
    snake_ready : in std_logic;
    snake_valid : out std_logic;
    apple_ready : in std_logic;
    apple_valid : out std_logic;
    col_ready : in std_logic;
    col_start : out std_logic;
    collision: in std_logic_vector(1 downto 0);
    snake_size : in std_logic_vector(5 downto 0);
    game_mode : out std_logic_vector(1 downto 0)
);
end component;

component col_detect is
    port(
        clk : in std_logic;
        rst : in std_logic;
        snake_array : in snake;
        snake_size: in std_logic_vector(5 downto 0);
        apple_pos : in std_logic_vector(5 downto 0);
        col_ready : out std_logic;
        col_start : in std_logic;
        collision : out std_logic_vector(1 downto 0)
    );
end component;

signal ram_we_r : std_logic;
signal ram_addr_r : std_logic_vector(8 downto 0);
signal ram_data_r : std_logic_vector(7 downto 0);
signal delay_cnt_done : std_logic;
signal cnt_out : std_logic_vector(24 downto 0);
signal snake_s : snake;
signal snake_head: std_logic_vector(5 downto 0);
signal snake_s_size : std_logic_vector(5 downto 0);
signal apple_pos_s : std_logic_vector(5 downto 0);
signal game_state : std_logic_vector(1 downto 0);
signal snake_valid, snake_ready : std_logic;
signal snake_size_inc, snake_reset : std_logic;
signal apple_valid, apple_ready : std_logic;
signal col_start, col_ready : std_logic;
signal collision : std_logic_vector(1 downto 0);
signal control : std_logic_vector(1 downto 0);
signal cnt_out_sym : std_logic_vector(9 downto 0);

begin

snake_head <= snake_s(0)(6 downto 5) & snake_s(0)(3 downto 0);

speed_timer_inst : speed_timer
port map(
    clk => clk,
    rst => rst,
    cnt_out => cnt_out
);
cnt_out_sym <= cnt_out(9 downto 0);
delay_cnt_done <= '1' when unsigned(cnt_out) = 0 else '0';
--delay_cnt_done <= '1' when unsigned(cnt_out_sym) = 0 else '0';

snk_pos_inst : snk_pos
port map(
    clk => clk,
    rst => rst,
    control => control,
    snake_array => snake_s,
    snake_size => snake_s_size,
    ready => snake_ready,
    valid => snake_valid,
    snake_size_inc => snake_size_inc,
    snake_reset => snake_reset
);
apple_pos_inst : apple_pos
port map(
    clk => clk,
    rst => rst,
    pos => apple_pos_s,
    ready => apple_ready,
    valid => apple_valid,
    snake_array => snake_s,
    snake_size => snake_s_size
);

col_detect_inst : col_detect
port map(
    clk => clk,
    rst => rst,
    snake_array => snake_s,
    snake_size => snake_s_size,
    apple_pos => apple_pos_s,
    col_ready => col_ready,
    col_start => col_start,
    collision => collision
);
world_gen_inst: world_gen
port map(
    rst => rst,
    clk => clk,
    ram_we => ram_we,
    ram_addr => ram_addr,
    ram_data => ram_data,
    game_state => game_state,
    snake_array => snake_s,
    snake_size => snake_s_size,
    apple_pos => apple_pos_s
);        
         
game_fsm_inst: game_fsm
port map(
    rst => rst,
    clk => clk,
    go => delay_cnt_done,
    control_in => user_control,
    control_out => control,
    snake_reset => snake_reset,
    snake_size_inc => snake_size_inc,
    snake_ready => snake_ready,
    snake_valid => snake_valid,
    apple_ready => apple_ready,
    apple_valid => apple_valid,
    col_ready => col_ready,
    col_start => col_start,
    collision => collision,
    snake_size => snake_s_size,
    game_mode => game_state    
);
  
end Behavioral;
