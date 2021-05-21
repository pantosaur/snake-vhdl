--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.ALL;

entity clk_div_2000 is
  Port(
	rst : in std_logic;
	clk_i : in std_logic;
	clk_o : out std_logic
      );
end clk_div_2000;

architecture clk_div_2000_arch of clk_div_2000 is
  signal clk_cnt : std_logic_vector(10 downto 0);
  signal clk_o_r : std_logic;
begin
  clk_o <= clk_o_r;
  sync: process(rst, clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if rst = '1' then
	clk_o_r <= '0';
	clk_cnt <= (others => '0');
      else
	if unsigned(clk_cnt) = 999 then
	  clk_cnt <= (others => '0');
	  clk_o_r <= not clk_o_r;
	else
	  clk_cnt <= std_logic_vector(unsigned(clk_cnt) + 1);
	  clk_o_r <= clk_o_r;
	end if;
      end if;
    end if;
  end process;
end architecture;
