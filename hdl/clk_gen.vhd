--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity clk_gen is
port(
    clk_in : in std_logic;
    clk_game : out std_logic;
    clk_display : out std_logic;
    locked : out std_logic;
    locked2 : out std_logic
);
end clk_gen;

architecture Behavioral of clk_gen is

signal clk_game_in : std_logic;
signal clk_game_in_buf : std_logic;
signal clk_game_fb : std_logic;
signal clk_game_fb_buf : std_logic;
signal clk_game_out : std_logic;
signal clk_game_out_buf : std_logic;
signal clk_game_locked : std_logic;

signal clk_display_in : std_logic;
signal clk_display_in_buf : std_logic;
signal clk_display_fb : std_logic;
signal clk_display_fb_buf : std_logic;
signal clk_display_out : std_logic;
signal clk_display_out_buf : std_logic;
signal clk_display_locked : std_logic;

begin
--CLK_GEN PORT MAPPING
--INPUTS
clk_game_in <= clk_in;

--OUTPUTS
clk_game <= clk_game_out_buf;
clk_display <= clk_display_out_buf;
locked <= clk_game_locked;
locked2 <= clk_display_locked;

MMCE_BASE_CLK_GAME: MMCME2_BASE
generic map(
    BANDWIDTH => ("OPTIMIZED"),
    CLKOUT4_CASCADE => FALSE,
    STARTUP_WAIT => FALSE,
    DIVCLK_DIVIDE => (1),
    CLKFBOUT_MULT_F => (10.000),
    CLKFBOUT_PHASE => (0.000),
    CLKOUT0_DIVIDE_F => (10.000),
    CLKOUT0_PHASE =>  (0.000),
    CLKOUT0_DUTY_CYCLE => (0.500),
    CLKIN1_PERIOD => (10.000))
  port map
   (
    CLKFBOUT => clk_game_fb,
    CLKFBOUTB => open,
    CLKOUT0 => clk_game_out,
    CLKOUT0B => open,
    CLKOUT1 => open,
    CLKOUT1B => open,
    CLKOUT2 => open,
    CLKOUT2B => open,
    CLKOUT3 => open,
    CLKOUT3B => open,
    CLKOUT4 => open,
    CLKOUT5 => open,
    CLKOUT6 => open,
--Input clock control
    CLKFBIN => clk_game_fb_buf,
    CLKIN1 => clk_game_in_buf,
--Other control and status signals
    LOCKED => clk_game_locked,
    PWRDWN => '0',
    RST => '0'
    );

BUFG_clk_game_fb:  BUFG
port map(
    O => clk_game_fb_buf,
    I => clk_game_fb
);

BUFG_clk_game_out: BUFG
port map(
O => clk_game_out_buf,
I => clk_game_out
);

IBUF_clk_game_in: IBUF
port map(
O => clk_game_in_buf,
I => clk_in
);

MMCE_BASE_CLK_DISPLAY: MMCME2_BASE
generic map(
    BANDWIDTH => ("OPTIMIZED"),
    CLKOUT4_CASCADE => FALSE,
    STARTUP_WAIT => FALSE,
    DIVCLK_DIVIDE => (5),
    CLKFBOUT_MULT_F => (32.000),
    CLKFBOUT_PHASE => (0.000),
    CLKOUT0_DIVIDE_F => (128.000),
    CLKOUT0_PHASE =>  (0.000),
    CLKOUT0_DUTY_CYCLE => (0.500),
    CLKIN1_PERIOD => (10.000))
  port map
   (
    CLKFBOUT => clk_display_fb,
    CLKFBOUTB => open,
    CLKOUT0 => clk_display_out,
    CLKOUT0B => open,
    CLKOUT1 => open,
    CLKOUT1B => open,
    CLKOUT2 => open,
    CLKOUT2B => open,
    CLKOUT3 => open,
    CLKOUT3B => open,
    CLKOUT4 => open,
    CLKOUT5 => open,
    CLKOUT6 => open,
--Input clock control
    CLKFBIN => clk_display_fb_buf,
    CLKIN1 => clk_display_in_buf,
--Other control and status signals
    LOCKED => clk_display_locked,
    PWRDWN => '0',
    RST => '0'
    );

BUFG_clk_display_fb:  BUFG
port map(
    O => clk_display_fb_buf,
    I => clk_display_fb
);

BUFG_clk_display_out: BUFG
port map(
O => clk_display_out_buf,
I => clk_display_out
);

IBUF_clk_display_in: IBUF
port map(
O => clk_display_in_buf,
I => clk_game_out_buf
);


end Behavioral;
