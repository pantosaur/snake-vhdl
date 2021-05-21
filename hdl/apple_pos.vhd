--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.snake_package.all;

entity apple_pos is
Port ( 
    clk : in std_logic;
    rst : in std_logic;
    pos : out std_logic_vector(5 downto 0);
    ready : out std_logic;
    valid : in std_logic;
    snake_array : in snake;
    snake_size : in std_logic_vector(5 downto 0)
);
end apple_pos;

architecture Behavioral of apple_pos is

signal seed : std_logic_vector(31 downto 0);
signal pos_r, pos_r_temp : std_logic_vector(5 downto 0);
signal ready_r : std_logic;
signal cnt_r : std_logic_vector(5 downto 0);

type state_T is (a,b,c,d,e);
signal state : state_T;

begin
pos <= pos_r;
ready <= ready_r;
apple: process(rst, clk)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            state <= a;
            pos_r <= (others => '0');
            pos_r_temp <= (others => '0');
            cnt_r <= (others => '0');
            ready_r <= '1';
        else
            case state is
                when a =>
                    if valid = '1' then
                        state <= b;
                        pos_r_temp <= seed(31 downto 26);
                        pos_r <= pos_r;
                        cnt_r <= (others => '0');
                        ready_r <= '0';
                    else
                        state <= a;
                        pos_r_temp <= (others => '0');
                        pos_r <= pos_r;
                        cnt_r <= (others => '0');
                        ready_r <= '1';
                    end if;
                when b =>
                    if pos_r_temp = snake_array(0)(6 downto 5) & snake_array(0)(3 downto 0) then
                        state <= d;
                        pos_r_temp <= std_logic_vector(unsigned(pos_r_temp) + 1);
                        pos_r <= pos_r;
                        cnt_r <= (others => '0');
                        ready_r <= '0';
                    else
                        state <= c;
                        pos_r_temp <= pos_r_temp;
                        pos_r <= pos_r;
                        cnt_r <= std_logic_vector(unsigned(cnt_r) + 1);
                        ready_r <= '0';
                    end if;
                when c =>
                    if cnt_r = snake_size then
                        state <= e;
                        pos_r_temp <= pos_r_temp;
                        pos_r <= pos_r_temp;
                        cnt_r <= (others => '0');
                        ready_r <= '0';
                    elsif pos_r_temp = snake_array(to_integer(unsigned(cnt_r)))(6 downto 5) & snake_array(to_integer(unsigned(cnt_r)))(3 downto 0) then
                        state <= d;
                        pos_r_temp <= std_logic_vector(unsigned(pos_r_temp) + 1);
                        pos_r <= pos_r;
                        cnt_r <= (others => '0');
                        ready_r <= '0';
                    else
                        state <= c;
                        pos_r_temp <= pos_r_temp;
                        pos_r <= pos_r;
                        cnt_r <= std_logic_vector(unsigned(cnt_r) + 1);
                        ready_r <= '0';
                    end if;
                when d =>
                    if pos_r_temp /= snake_array(0)(6 downto 5) & snake_array(0)(3 downto 0) then
                        state <= c;
                        pos_r_temp <= pos_r_temp;
                        pos_r <= pos_r;
                        cnt_r <= std_logic_vector(unsigned(cnt_r) + 1);
                        ready_r <= '0';
                    else
                        state <= d;
                        pos_r_temp <= std_logic_vector(unsigned(pos_r_temp) + 1);
                        pos_r <= pos_r;
                        cnt_r <= (others => '0');
                        ready_r <= '0';
                    end if;
                when others => --e
                    state <= a;
                    pos_r_temp <= (others => '0');
                    pos_r <= pos_r;
                    cnt_r <= (others => '0');
                    ready_r <= '1';
            end case;
        end if;
    end if;
end process;

RNG: process(rst, clk)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            seed <= std_logic_vector(to_unsigned(7,32));
        else
            seed <= std_logic_vector(unsigned(seed xor std_logic_vector(unsigned((seed xor std_logic_vector((unsigned(seed) sll 13)))) srl 17)) sll 5);
        end if;
    end if;
end process;
end Behavioral;
