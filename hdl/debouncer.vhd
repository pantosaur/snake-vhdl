--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Generic(
        IO_LOGIC : std_logic := '1'
    );
    Port(
        rst : in std_logic;
        clk : in std_logic;
        b_i : in std_logic;
        b_o : out std_logic
    );
end entity;

architecture debouncer_arch of debouncer is
    signal shift_reg : std_logic_vector(7 downto 0);
    signal b_o_r : std_logic;
begin
b_o <= b_o_r;
sync: process
begin
    if clk'event and clk = '1' then
        if rst = '1' then
        shift_reg <= (others => not IO_LOGIC);
        b_o_r <= not IO_LOGIC;
        else
        shift_reg <= shift_reg(6 downto 0) & b_i;
            if shift_reg = "00000000" then
                b_o_r <= '0';
            elsif shift_reg = "11111111" then
            b_o_r <= '1';
            else
            b_o_r <= b_o_r;
            end if;
        end if;
    end if;
end process;
end architecture;
