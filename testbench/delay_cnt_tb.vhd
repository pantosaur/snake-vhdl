--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delay_cnt_tb is
end delay_cnt_tb;

architecture Behavioral of delay_cnt_tb is
component delay_cnt is
port(
    clk : in std_logic;
    rst : in std_logic;
    delay_load : in std_logic;
    cnt_out : out std_logic_vector(18 downto 0);
    cmd_delay : in std_logic_vector(18 downto 0)
);
end component;

signal clk_tb : std_logic;
signal rst_tb : std_logic;
signal delay_load_tb : std_logic := '0';
signal cnt_out_tb : std_logic_vector(18 downto 0);
signal cmd_delay_tb : std_logic_vector(18 downto 0) := (others => '0');


constant clk_period : time := 200 ns;

begin

uut: delay_cnt
port map(
    clk => clk_tb,
    rst => rst_tb,
    delay_load => delay_load_tb,
    cnt_out => cnt_out_tb,
    cmd_delay => cmd_delay_tb
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
    wait for 4* clk_period;
    rst_tb <= '0';
    wait for 10*clk_period;
    delay_load_tb <= '1';
    cmd_delay_tb <= "0000000000110000000";
    wait for clk_period;
    delay_load_tb <= '0';
    cmd_delay_tb <= (others => '0');
    wait for clk_period * 50;
    delay_load_tb <= '1';
    cmd_delay_tb <= "0000000000110000000";
    wait for clk_period;
    delay_load_tb <= '0';
    cmd_delay_tb <= (others => '0');
    wait for clk_period * 1000;
    delay_load_tb <= '1';
    cmd_delay_tb <= "0000000000110000000";
    wait for clk_period;
    delay_load_tb <= '0';
    cmd_delay_tb <= (others => '0');
    wait;
end process;


end Behavioral;
