--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.snake_package.all;

entity snk_pos is
    port(
        clk : in std_logic;
        rst : in std_logic;
        snake_size : out std_logic_vector(5 downto 0);
        snake_array : out snake;
        ready : out std_logic;                              --handshake
        valid : in std_logic;
        snake_reset : in std_logic;                         --data signals
        snake_size_inc : in std_logic;
        control : in std_logic_vector(1 downto 0)
        );
end snk_pos;

architecture Behavioral of snk_pos is

signal snake_array_r : snake;
signal snake_size_r : std_logic_vector(5 downto 0);
signal direction_r : std_logic_vector(1 downto 0);
signal ready_r : std_logic;

--constants for directions
constant DOWN : integer := 0;
constant LEFT : integer := 1;
constant RIGHT : integer := 2;
constant UP : integer := 3;

begin

snake_array <= snake_array_r;
--snake_size <= std_logic_vector(to_unsigned(5,6));
snake_size <= snake_size_r;
ready <= '1';       --always '1' since all processing is done in a single cycle

snake_proc: process(rst,clk)
begin
    if clk'event and clk='1' then
        if rst = '1' then
            snake_array_r <= (others => (others => '0'));
            direction_r <= std_logic_vector(to_unsigned(2,2));
        else
            if valid = '1' then
                if snake_reset = '1' then
                    snake_array_r <= (0 => "00100111", others => (others => '1'));
                    direction_r <= std_logic_vector(to_unsigned(2,2));
                else
                    case to_integer(unsigned(control)) is
                        when DOWN =>
                            if direction_r = std_logic_vector(to_unsigned(UP,2)) then
                                direction_r <= direction_r;
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) - 32);
                            else
                                direction_r <= std_logic_vector(to_unsigned(DOWN,2));
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) + 32);
                            end if;
                        when LEFT =>
                            if direction_r = std_logic_vector(to_unsigned(RIGHT,2)) then
                                direction_r <= direction_r;
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) + 1);
                            else
                                direction_r <= std_logic_vector(to_unsigned(LEFT,2));
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) - 1);
                            end if;
                        when RIGHT =>
                            if direction_r = std_logic_vector(to_unsigned(LEFT,2)) then
                                direction_r <= direction_r;
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) - 1);
                            else
                                direction_r <= std_logic_vector(to_unsigned(RIGHT,2));
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) + 1);
                            end if;
                        when others => ---UP
                            if direction_r = std_logic_vector(to_unsigned(DOWN,2)) then
                                direction_r <= direction_r;
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) + 32);
                            else
                                direction_r <= std_logic_vector(to_unsigned(UP,2));
                                snake_array_r <= snake_array_r(62 downto 0) & std_logic_vector(unsigned(snake_array_r(0)) - 32);
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end if;
end process;

snake_size_proc: process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            snake_size_r <= "000001";
        else
            if valid = '1' then
                if snake_reset = '1' then
                    snake_size_r <= "000001";
                else
                    if snake_size_inc = '1' then
                        snake_size_r <= std_logic_vector(unsigned(snake_size_r) + 1);
                    else
                        snake_size_r <= snake_size_r;
                    end if;
                end if;
            else
                snake_size_r <= snake_size_r;
            end if;
        end if;
    end if;
end process;

end Behavioral;
