--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity speed_timer is
port(
    clk : in std_logic;
    rst : in std_logic;
    cnt_out : out std_logic_vector(24 downto 0)
);
end speed_timer;

architecture Behavioral of speed_timer is

signal cnt_out_reg : std_logic_vector(24 downto 0);

begin
cnt_out <= cnt_out_reg;

count: process(clk, rst)
begin
    if clk'event and clk='1' then
        if rst = '1' then
            cnt_out_reg <= (others => '0');
        else
            cnt_out_reg <= std_logic_vector(unsigned(cnt_out_reg) - 1);
        end if;
    end if;
end process;
end Behavioral;
