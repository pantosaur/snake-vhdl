--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.snake_package.all;

entity world_gen is
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
end world_gen;

architecture Behavioral of world_gen is

type ROM_word_t is array(511 downto 0) of std_logic_vector(7 downto 0);

  
constant rom_welcome : ROM_word_t := (
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 1
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 2 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 3 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"63", X"41", X"5D", X"49", X"49", X"7F", X"41", X"00", 
X"41", X"7F", X"42", X"0C", X"42", X"7F", X"41", X"00", X"1C", X"22", X"41", X"41", X"41", X"22", X"1C", X"00", 
X"22", X"41", X"41", X"41", X"41", X"22", X"1C", X"00", X"60", X"40", X"40", X"40", X"41", X"7F", X"41", X"00", 
X"63", X"41", X"5D", X"49", X"49", X"7F", X"41", X"00", X"01", X"1F", X"61", X"14", X"61", X"1F", X"01", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 4
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
);
constant rom_loss : ROM_word_t := (
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 1
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 2 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 3 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"03", X"01", X"41", X"7F", X"41", X"01", X"03", X"00", 
X"40", X"7C", X"4A", X"09", X"4A", X"7C", X"40", X"00", X"63", X"41", X"5D", X"49", X"49", X"7F", X"41", X"00", 
X"03", X"01", X"1D", X"09", X"49", X"7F", X"41", X"00", X"63", X"41", X"5D", X"49", X"49", X"7F", X"41", X"00", 
X"1C", X"22", X"41", X"41", X"41", X"7F", X"41", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 4
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
);
constant rom_win : ROM_word_t := (
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 1
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 2 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 3 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"01", X"7F", X"11", X"0C", X"42", X"7F", X"41", X"00", 
X"00", X"41", X"41", X"7F", X"41", X"41", X"00", X"00", X"01", X"1F", X"61", X"14", X"61", X"1F", X"01", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00",         --row 4
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", 
X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00"
);

constant WELCOME : integer := 0;
constant GAME : integer := 1;
constant LOSS : integer := 2;
constant WIN : integer := 3;

--constants for next_display
constant CLEAR : integer := 0;
constant SNEK : integer := 1;
constant APPLE : integer := 2;
constant NONE : integer := 3;

--constants for things to draw



--signal ram_we_p, ram_we_f : std_logic;
--signal ram_addr_p, ram_addr_f : std_logic_vector(8 downto 0);
--signal ram_data_p, ram_data_f : std_logic_vector(7 downto 0);

signal ram_buff_we_p, ram_buff_we_f : std_logic;
signal ram_buff_addr_p, ram_buff_addr_f : std_logic_vector(8 downto 0);
signal ram_buff_data_in_p, ram_buff_data_in_f : std_logic_vector(7 downto 0);
signal ram_buff_addr_out : std_logic_vector(8 downto 0);
signal ram_buff_data_out : std_logic_vector(7 downto 0);

signal rom_welcome_data_out : std_logic_vector(7 downto 0);
signal rom_loss_data_out : std_logic_vector(7 downto 0);
signal rom_win_data_out : std_logic_vector(7 downto 0);

signal ram_addr_r : std_logic_vector(8 downto 0);
signal ram_we_r : std_logic;

type state_T is (start, init_clear, init_snake, init_apple, inc_address, inc_count, done);
signal state : state_T;
signal cnt_sym : std_logic_vector(5 downto 0);
signal cnt_sym_max : std_logic_vector(5 downto 0);
signal cnt_addr : std_logic_vector(2 downto 0);
signal we : std_logic;
signal next_init_state : state_T;
signal current_display : std_logic_vector(2 downto 0);
signal next_display : std_logic_vector(2 downto 0);

type RAM_2p_T is array (0 to 511) of std_logic_vector(7 downto 0);
signal RAM_buff : RAM_2p_T;

signal front_end_ready : std_logic;
signal front_end_valid : std_logic;

type front_end_state_T is (a,b,c,d,e);
signal front_end_state: front_end_state_T;

type snake_xy_T is array (63 downto 0) of std_logic_vector(5 downto 0);
signal snake_xy : snake_xy_T;

type block_T is array (7 downto 0) of std_logic_vector(7 downto 0);
constant snake_head_block : block_T := (x"3c",x"7e",x"ff",x"ff",x"ff",x"ff",x"7e",x"3c");
constant snake_block : block_T := (x"00",x"1c",x"22",x"41",x"41",x"41",x"22",x"1c");
constant apple_block : block_T := (x"00",x"00",x"08",x"08",x"3e",x"08",x"08",x"00");

begin
ram_we <= ram_we_r;
ram_addr <= ram_addr_r;
ram_data <= ram_buff_data_out when game_state = std_logic_vector(to_unsigned(GAME,2)) else
            rom_welcome_data_out when game_state = std_logic_vector(to_unsigned(WELCOME,2)) else
            rom_loss_data_out when game_state = std_logic_vector(to_unsigned(LOSS,2)) else
            rom_win_data_out;

front_end_valid <= '1' when state = done else '0';

                
next_display <= std_logic_vector(to_unsigned(SNEK,3)) when current_display = std_logic_vector(to_unsigned(CLEAR,3)) else
                std_logic_vector(to_unsigned(APPLE,3)) when current_display = std_logic_vector(to_unsigned(SNEK,3)) else
                std_logic_vector(to_unsigned(NONE,3));
                
next_init_state <= init_clear when next_display = std_logic_vector(to_unsigned(CLEAR,3)) else
                    init_snake when next_display = std_logic_vector(to_unsigned(SNEK,3)) else
                    init_apple when next_display = std_logic_vector(to_unsigned(APPLE,3)) else
                    init_clear;

cnt_sym_max <=      std_logic_vector(to_unsigned(63,6)) when current_display = std_logic_vector(to_unsigned(CLEAR,3)) else
                    std_logic_vector(unsigned(snake_size) - 1) when current_display = std_logic_vector(to_unsigned(SNEK,3)) else
                    std_logic_vector(to_unsigned(1,6)) when current_display = std_logic_vector(to_unsigned(APPLE,3))
                    else std_logic_vector(to_unsigned(63,6));
                    
snake_xy_proc : process(snake_array)
begin
for I in 0 to 63 loop
    snake_xy(I) <= snake_array(I)(6) & snake_array(I)(5) & snake_array(I)(3) & snake_array(I)(2) & snake_array(I)(1) & snake_array(I)(0);       
end loop; 
end process;
             
output_reg : process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            ram_buff_we_p <= '0';
            ram_buff_addr_p <= (others => '0');
            ram_buff_data_in_p <= (others => '0');
        else
            ram_buff_we_p <= ram_buff_we_f;
            ram_buff_addr_p <= ram_buff_addr_f;
            ram_buff_data_in_p <= ram_buff_data_in_f;
        end if;
    end if;
end process;


back_end : process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            state <= start;
            cnt_sym <= (others => '0');
            cnt_addr <= (others => '0');
            we <= '0';
            current_display <= std_logic_vector(to_unsigned(NONE,3));
        else
            case state is
                when start =>
                    if front_end_ready = '1' then   
                        if unsigned(game_state) = GAME then
                            state <= init_clear;
                            cnt_sym <= (others => '0');
                            cnt_addr <= (others => '0');
                            we <= '1';
                            current_display <= std_logic_vector(to_unsigned(CLEAR,3));
                        else
                            state <= init_clear;
                            cnt_sym <= (others => '0');
                            cnt_addr <= (others => '0');
                            we <= '1';
                            current_display <= std_logic_vector(to_unsigned(CLEAR,3));
                        end if;
                    else
                        state <= start;
                        cnt_sym <= (others => '0');
                        cnt_addr <= (others => '0');
                        we <= '0';
                        current_display <= std_logic_vector(to_unsigned(NONE,3));
                    end if;
                when init_clear =>
                    state <= inc_address;
                    cnt_sym <= cnt_sym;
                    cnt_addr <= std_logic_vector(unsigned(cnt_addr) + 1);
                    we <= '1';
                    current_display <= current_display;
                when inc_address =>
                    if unsigned(cnt_addr) = 7 then
                        if cnt_sym = cnt_sym_max then
                            if to_integer(unsigned(next_display)) = NONE then
                                state <= done;
                                cnt_sym <= (others => '0');
                                cnt_addr <= (others => '0');
                                we <= '0';
                                current_display <= next_display;
                            else
                                state <= next_init_state;
                                cnt_sym <= (others => '0');
                                cnt_addr <= (others => '0');
                                we <= '1';
                                current_display <= next_display;
                            end if;
                        else
                            state <= inc_count;
                            cnt_sym <= std_logic_vector(unsigned(cnt_sym) + 1);
                            cnt_addr <= (others => '0');
                            we <= '1';
                            current_display <= current_display;
                        end if;
                    else
                        state <= inc_address;
                        cnt_sym <= cnt_sym;
                        cnt_addr <= std_logic_vector(unsigned(cnt_addr) + 1);
                        we <= '1';
                        current_display <= current_display;
                    end if;
                when inc_count =>
                    state <= inc_address;
                    cnt_sym <= cnt_sym;
                    cnt_addr <= std_logic_vector(unsigned(cnt_addr) + 1);
                    we <= '1';
                    current_display <= current_display;
                when init_snake =>
                    state <= inc_address;
                    cnt_sym <= cnt_sym;
                    cnt_addr <= std_logic_vector(unsigned(cnt_addr) + 1);
                    we <= '1';
                    current_display <= current_display;
                when init_apple =>
                    state <= inc_address;
                    cnt_sym <= cnt_sym;
                    cnt_addr <= std_logic_vector(unsigned(cnt_addr) + 1);
                    we <= '1';
                    current_display <= current_display;
                when others => --done
                    state <= start;
                    cnt_sym <= (others => '0');
                    cnt_addr <= (others => '0');
                    we <= '0';
                    current_display <= current_display;
            end case;                
        end if;
    end if;
end process;

OFL : process(current_display,we, cnt_sym, cnt_addr, snake_array, apple_pos, snake_xy)
begin
    case to_integer(unsigned(current_display)) is
        when CLEAR =>
            ram_buff_addr_f <= cnt_sym & cnt_addr;
            ram_buff_data_in_f <= "00000000";
            ram_buff_we_f <= we;
        when SNEK =>
            if snake_array(to_integer(unsigned(cnt_sym)))(7) = '1' or snake_array(to_integer(unsigned(cnt_sym)))(4) = '1' then
                ram_buff_we_f <= '0';
            else
                ram_buff_we_f <= we;
            end if;
            ram_buff_addr_f <= std_logic_vector(unsigned(snake_xy(to_integer(unsigned(cnt_sym))))) & cnt_addr;
            if unsigned(cnt_sym) = 0 then
                ram_buff_data_in_f <= snake_head_block(to_integer(unsigned(cnt_addr)));
            else
                ram_buff_data_in_f <= snake_block(to_integer(unsigned(cnt_addr)));
            end if;
        when APPLE =>
            ram_buff_addr_f <= apple_pos & cnt_addr;
            ram_buff_data_in_f <= apple_block(to_integer(unsigned(cnt_addr)));
            ram_buff_we_f <= we;
        when others => --NONE
            ram_buff_addr_f <= (others => '0');
            ram_buff_data_in_f <= "00000000";
            ram_buff_we_f <= we;
    end case;
end process;

RAM_buff_proc : process(clk)
begin
    if clk'event and clk= '1' then
        if ram_buff_we_p = '1' then
            ram_buff(to_integer(unsigned(ram_buff_addr_p))) <= ram_buff_data_in_p;
        end if;
        ram_buff_data_out <= ram_buff(to_integer(unsigned(ram_buff_addr_out)));
    end if;
end process;

front_end : process(clk, rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            front_end_ready <= '0';
            ram_buff_addr_out <= (others => '0');
            ram_addr_r <= (others => '0');
            ram_we_r <= '0';
        else
            case front_end_state is
                when a =>
                    if front_end_valid = '1' then
                        front_end_state <= b;
                        front_end_ready <= '0';
                        ram_buff_addr_out <= (others => '0');
                        ram_addr_r <= (others => '0');
                        ram_we_r <= '0';
                    else
                        front_end_state <= a;
                        front_end_ready <= '1';
                        ram_buff_addr_out <= (others => '0');
                        ram_addr_r <= (others => '0');
                        ram_we_r <= '0';
                    end if;
                when b =>
                    front_end_state <= c;
                    front_end_ready <= '0';
                    ram_buff_addr_out <= std_logic_vector(unsigned(ram_buff_addr_out) + 1);
                    ram_addr_r <= (others => '0');
                    ram_we_r <= '1';
                when c =>
                    front_end_state <= d;
                    front_end_ready <= '0';
                    ram_buff_addr_out <= std_logic_vector(unsigned(ram_buff_addr_out) + 1);
                    ram_addr_r <= std_logic_vector(unsigned(ram_addr_r) + 1);
                    ram_we_r <= '1';
                when d =>
                    if unsigned(ram_buff_addr_out) = 511 then
                        front_end_state <= e;
                        front_end_ready <= '0';
                        ram_buff_addr_out <= (others => '0');
                        ram_addr_r <= std_logic_vector(unsigned(ram_addr_r) + 1);
                        ram_we_r <= '1';
                    else
                        front_end_state <= d;
                        front_end_ready <= '0';
                        ram_buff_addr_out <= std_logic_vector(unsigned(ram_buff_addr_out) + 1);
                        ram_addr_r <= std_logic_vector(unsigned(ram_addr_r) + 1);
                        ram_we_r <= '1';
                    end if;
                when others => --e
                    front_end_state <= a;
                    front_end_ready <= '1';
                    ram_buff_addr_out <= (others => '0');
                    ram_addr_r <= (others => '0');
                    ram_we_r <= '0';
            end case;
        end if;
    end if;
end process;

ROMs_proc : process(clk)
begin
    if clk'event and clk = '1' then
        rom_welcome_data_out <= rom_welcome(to_integer(unsigned(ram_buff_addr_out)));
        rom_loss_data_out <= rom_loss(to_integer(unsigned(ram_buff_addr_out)));
        rom_win_data_out <= rom_win(to_integer(unsigned(ram_buff_addr_out)));
    end if;
end process;


end Behavioral;
