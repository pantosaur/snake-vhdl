--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cmd_addr is
    port(
    clk : in std_logic;
    rst : in std_logic;
    cmd_inc : in std_logic;
    cmd_rst : in std_logic;
    addr_offset : in std_logic_vector(8 downto 0);
    cmd_max : out std_logic;
    addr_count : out std_logic_vector(8 downto 0)
);
end cmd_addr;

architecture Behavioral of cmd_addr is

signal addr_count_reg : std_logic_vector(8 downto 0);

begin

cmd_max <= '1' when addr_count_reg = "111111111" else '0';
addr_count <= addr_count_reg;

count: process(clk, rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            addr_count_reg <= (others => '0');
        else
            if cmd_rst = '1' then
                addr_count_reg <= addr_offset;
            elsif cmd_inc = '1' then
                addr_count_reg <= std_logic_vector(unsigned(addr_count_reg) + 1);
            else
                addr_count_reg <= addr_count_reg;
            end if;
        end if;
    end if;
end process;


end Behavioral;
