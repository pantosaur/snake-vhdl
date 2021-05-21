--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cmd_addr_tb is
end cmd_addr_tb;

architecture Behavioral of cmd_addr_tb is
component cmd_addr is
port(
    clk : in std_logic;
    rst : in std_logic;
    cmd_inc : in std_logic;
    cmd_rst : in std_logic;
    addr_offset : in std_logic_vector(8 downto 0);
    cmd_max : out std_logic;
    addr_count : out std_logic_vector(8 downto 0)
);
end component;

signal clk_tb : std_logic;
signal rst_tb : std_logic;
signal cmd_inc_tb : std_logic;
signal cmd_rst_tb : std_logic;
signal addr_offset_tb : std_logic_vector(8 downto 0);
signal cmd_max_tb : std_logic;
signal addr_count_tb : std_logic_vector(8 downto 0);

constant clk_period : time := 200 ns;



begin

uut: cmd_addr
port map(
    clk => clk_tb,
    rst => rst_tb,
    cmd_inc => cmd_inc_tb,
    cmd_rst => cmd_rst_tb,
    addr_offset => addr_offset_tb,
    cmd_max => cmd_max_tb,
    addr_count => addr_count_tb
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
    cmd_inc_tb <= '0';
    cmd_rst_tb <= '0';
    addr_offset_tb <= (others => '0');	
    rst_tb <= '1';
    wait for 4* clk_period;
    rst_tb <= '0';
    wait for 10*clk_period;
    cmd_rst_tb <= '1';
    addr_offset_tb <= "010101010";
    wait for clk_period;
    cmd_rst_tb <= '0';
    addr_offset_tb <= (others => '0');
    wait for 4* clk_period;
    cmd_inc_tb <= '1';
    wait for clk_period*5;
    cmd_inc_tb <= '0';
    wait for clk_period;
    cmd_inc_tb <= '1';
    wait for clk_period;
    cmd_inc_tb <= '0';
    wait for clk_period;
    cmd_rst_tb <= '1';
    cmd_inc_tb <= '1';
    addr_offset_tb <= "101010101";
    wait for clk_period;
    cmd_rst_tb <= '0';
    addr_offset_tb <= (others => '0');
    wait for 4* clk_period;
    cmd_inc_tb <= '1';
    wait for clk_period*5;
    cmd_inc_tb <= '0';
    wait for clk_period;
    cmd_inc_tb <= '1';
    wait;
end process;


end Behavioral;
