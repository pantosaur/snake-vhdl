--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity spi_master is
port(
    clk : in std_logic;
    
    ready : out std_logic;
    valid : in std_logic;
    data : in std_logic_vector(7 downto 0);
    
    sclk : out std_logic;
    sdin : out std_logic
    );
end spi_master;

architecture Behavioral of spi_master is
type state_T is (idle, start, transac);
signal state : state_T := idle;
signal data_r : std_logic_vector(7 downto 0) := (others => '0');
signal cs : std_logic := '1';
signal cnt : std_logic_vector(2 downto 0) := (others => '0');

begin
sdin <= data_r(7);
sclk <= cs or not clk;

spi_master: process(clk)
begin
    if clk'event and clk = '1' then
        case state is
            when idle =>
            if valid = '1' then
                state <= start;
                cs <= '0';
                data_r <= data;
                cnt <= (others => '0');
                ready <= '0';
            else
                state <= idle;
                cs <= '1';
                data_r <= (others => '0');
                cnt <= (others => '0');
                ready <= '1';
            end if;
            
            when start =>
                state <= transac;
                cs <= '0';
                data_r <= data_r(6 downto 0) & '0';
                cnt <= std_logic_vector(unsigned(cnt) + 1);
                ready <= '0';
            when transac =>
                if cnt = "111" then
                    state <= idle;
                    cs <= '1';
                    data_r <= (others => '0');
                    cnt <= (others => '0');
                    ready <= '1';
                else
                    state <= transac;
                    cs <= '0';
                    data_r <= data_r(6 downto 0) & '0';
                    cnt <= std_logic_vector(unsigned(cnt) + 1);
                    ready <= '0';
                end if;
                
            when others =>
                if valid = '1' then
                    state <= start;
                    cs <= '0';
                    data_r <= data;
                    cnt <= (others => '0');
                    ready <= '0';
                else
                    state <= idle;
                    cs <= '1';
                    data_r <= (others => '0');
                    cnt <= (others => '0');
                    ready <= '1';
                end if;
            end case;
        end if;
end process;


end Behavioral;
