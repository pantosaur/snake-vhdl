--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sync_io is
  Generic(
	   IO_LOGIC : std_logic := '1'
);
Port(
      rst : in std_logic;
      clk_front : in std_logic;
      clk_back : in std_logic;
      s_i : in std_logic;
      s_o : out std_logic
    );
end entity;

architecture sync_io_arch of sync_io is
  signal shift_reg : std_logic_vector(1 downto 0);
  signal s_i_reg : std_logic;
begin
  s_o <= shift_reg(1);

  front_end: process
  begin
    if clk_front'event and clk_front = '1' then
      if rst = '1' then
	   s_i_reg <= not IO_LOGIC;
      else
	   s_i_reg <= s_i;
      end if;
      end if;
    end process;

    back_end: process
    begin
      if clk_back'event and clk_back = '1' then
	if rst = '1' then
	  shift_reg <= (others => not IO_LOGIC);
	else
	  shift_reg <= shift_reg(0) & s_i_reg;
	end if;
      end if;
    end process;
end architecture;
