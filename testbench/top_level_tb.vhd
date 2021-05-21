--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_tb is
end top_level_tb;

architecture Behavioral of top_level_tb is

component top_level
port(
    rst_n : in std_logic;
    clk_100mhz : in std_logic;
    
    pbs: in std_logic_vector(4 downto 0);
    leds_o : out std_logic_vector(7 downto 0);
    
    oled_vdd : out std_logic;
    oled_vbat : out std_logic;
    oled_res : out std_logic;
    
    oled_dc : out std_logic;
    oled_sclk : out std_logic;
    oled_sdin : out std_logic
    );
end component;

signal rst_n_tb : std_logic;
signal clk_100mhz_tb : std_logic;

signal pbs_tb: std_logic_vector(4 downto 0) := "00000";

signal leds_o_tb : std_logic_vector(7 downto 0);

signal oled_vdd_tb : std_logic;
signal oled_vbat_tb : std_logic;
signal oled_res_tb : std_logic;

signal oled_dc_tb : std_logic;
signal oled_sclk_tb : std_logic;
signal oled_sdin_tb : std_logic;

constant clk_period : time := 10 ns;

begin
uut: top_level
port map(
rst_n => rst_n_tb,
clk_100mhz => clk_100mhz_tb,
pbs => pbs_tb,
leds_o => leds_o_tb,
oled_vdd => oled_vdd_tb,
oled_vbat => oled_vbat_tb,
oled_res => oled_res_tb,
oled_dc => oled_dc_tb,
oled_sclk => oled_sclk_tb,
oled_sdin => oled_sdin_tb
);

-- Clock process definitions
clk_process :process
begin
    clk_100mhz_tb <= '0';
    wait for clk_period/2;
    clk_100mhz_tb <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin
pbs_tb(0) <= '0';
rst_n_tb <= '0';
wait for clk_period*4;
rst_n_tb <= '1';
wait for clk_period*1200;
pbs_tb(0) <= '1';
wait for clk_period*12000;
pbs_tb(0)<= '0';

wait;
end process;

end Behavioral;
