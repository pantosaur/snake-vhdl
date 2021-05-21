--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use work.snake_package.all;

entity col_detect is
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
end col_detect;

architecture Behavioral of col_detect is

--constants for collision types
constant NONE : integer := 0;
constant WALL : integer := 1;
constant TAIL : integer := 2;
constant APPLE : integer := 3;

signal start_wall, done_wall, col_wall : std_logic;
signal start_tail, done_tail, col_tail : std_logic;
signal start_apple, done_apple, col_apple : std_logic;

type state_T is (a,b,c,d);
signal state : state_T;

type tail_proc_state_T is (idle, first, active, done_col, done_nocol);
signal tail_proc_state : tail_proc_state_T;

signal tail_count : std_logic_vector(5 downto 0);
signal tail_comp : std_logic;

signal snake_head_temp : std_logic_vector(5 downto 0);

begin

snake_head_temp <= snake_array(0)(6 downto 5) & snake_array(0)(3 downto 0);
start_wall <= col_start;
start_tail <= col_start;
start_apple <= col_start;
col_ready <= done_wall and done_tail and done_apple;

wall_check_col: process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            col_wall <= '0';
        else
            if start_wall = '1' then
                if snake_array(0)(7) = '1' or snake_array(0)(4) = '1' then
                    col_wall <= '1';
                else
                    col_wall <= '0';
                end if;
                done_wall <= '1';
            else
                col_wall <= col_wall;
                done_wall <= '1';
            end if;
        end if;
    end if;
end process;



apple_check_col: process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            col_apple <= '0';
            done_apple <= '0';
        else
            if start_apple = '1' then
                if snake_head_temp = apple_pos  then
                    col_apple <= '1';
                else
                    col_apple <= '0';
                end if;
                done_apple <= '1';
            else
                col_apple <= col_apple;
                done_apple <= '1';
            end if;
        end if;
    end if;
end process;

tail_check_col: process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            tail_proc_state <= idle;
            tail_count <= (others => '0');
            done_tail <= '1';
            col_tail <= '0';
        else
            case tail_proc_state is
                when idle =>
                    if start_tail = '1' then
                        tail_proc_state <= first;
                        tail_count <= "000001";
                        done_tail <= '0';
                        col_tail <= col_tail;
                    else
                        tail_proc_state <= idle;
                        tail_count <= "000000";
                        done_tail <= '1';
                        col_tail <= col_tail;
                    end if;
                when first =>
                    if tail_count = snake_size then
                        tail_proc_state <= done_nocol;
                        tail_count <= "000000";
                        done_tail <= '1';
                        col_tail <= '0';
                    elsif snake_array(to_integer(unsigned(tail_count))) = snake_array(0) then
                        tail_proc_state <= done_col;
                        tail_count <= "000000";
                        done_tail <= '1';
                        col_tail <= '1';
                    else
                        tail_proc_state <= active;
                        tail_count <= std_logic_vector(unsigned(tail_count) + 1);
                        done_tail <= '0';
                        col_tail <= col_tail;
                    end if;
                when active =>
                    if tail_count =  snake_size then
                        tail_proc_state <= done_nocol;
                        tail_count <= "000000";
                        done_tail <= '1';
                        col_tail <= '0';
                    elsif snake_array(to_integer(unsigned(tail_count))) = snake_array(0) then
                        tail_proc_state <= done_col;
                        tail_count <= "000000";
                        done_tail <= '1';
                        col_tail <= '1';
                    else
                        tail_proc_state <= active;
                        tail_count <= std_logic_vector(unsigned(tail_count) + 1);
                        done_tail <= '0';
                        col_tail <= col_tail;
                    end if;
                when done_col =>
                    tail_proc_state <= idle;
                    tail_count <= "000000";
                    done_tail <= '1';
                    col_tail <= col_tail;
                when done_nocol =>
                    tail_proc_state <= idle;
                    tail_count <= "000000";
                    done_tail <= '1';
                    col_tail <= col_tail;
                when others =>
                    tail_proc_state <= idle;
                    tail_count <= "000000";
                    done_tail <= '1';
                    col_tail <= col_tail;
            end case;
        end if;
    end if;
end process;

collision_out: process(col_wall, col_tail, col_apple)
begin
    if col_wall = '1' then
        collision <= std_logic_vector(to_unsigned(WALL,2));
    elsif col_tail = '1' then
        collision <= std_logic_vector(to_unsigned(TAIL,2));
    elsif col_apple = '1' then
        collision <= std_logic_vector(to_unsigned(APPLE,2));
    else
        collision <= std_logic_vector(to_unsigned(NONE,2));
    end if;
end process;

end Behavioral;
