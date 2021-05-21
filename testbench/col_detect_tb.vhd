--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.snake_package.all;

entity col_detect_tb is
end col_detect_tb;

architecture Behavioral of col_detect_tb is

component col_detect
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

signal clk_tb : std_logic;
signal rst_tb : std_logic;
signal snake_array_tb : snake := (0 => "00000001", 4 => "00000001", others => (others => '0'));
signal snake_size_tb : std_logic_vector(5 downto 0) := "011111";
signal apple_pos_tb : std_logic_vector(5 downto 0) := "111111";
signal col_ready_tb : std_logic;
signal col_start_tb : std_logic := '0';
signal collision_tb : std_logic_vector(1 downto 0);

constant clk_period : time := 10 ns;

begin
uut: col_detect
port map(
clk => clk_tb,
rst => rst_tb,
snake_array => snake_array_tb,
snake_size => snake_size_tb,
apple_pos => apple_pos_tb,
col_ready => col_ready_tb,
col_start => col_start_tb,
collision => collision_tb
);

-- Clock process definitions
clk_process :process
begin
    clk_tb <= '0';
    wait for clk_period/2;
    clk_tb <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin
rst_tb <= '1';
wait for clk_period*4;
rst_tb <= '0';
wait for clk_period*10;
col_start_tb <= '1';
wait for clk_period;
col_start_tb <= '0';

wait;
end process;

end Behavioral;
