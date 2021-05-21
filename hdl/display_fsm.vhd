--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_fsm is
port(
clk : in std_logic;
rst : in std_logic;

dc : out std_logic;
wr_data_sel : out std_logic;

spi_ready : in std_logic;
spi_valid : out std_logic;

pbs : in std_logic_vector(4 downto 0);

cmd_inc : out std_logic;
cmd_rst : out std_logic;
addr_offset : out std_logic_vector(8 downto 0);
cmd_max : in std_logic;

delay_load : out std_logic;
delay_cnt_done : in std_logic;

cmd_data : in std_logic_vector(7 downto 0);

vdd : out std_logic;
vbat : out std_logic;
res : out std_logic
);
end display_fsm;

architecture Behavioral of display_fsm is

--pbs constants
constant PWR_TOGGLE : integer := 0;

--ROM bits
constant VDD_SET_BIT : integer := 0;
constant VDD_BIT : integer := 1;
constant VBAT_SET_BIT : integer := 2;
constant VBAT_BIT : integer := 3;
constant RES_SET_BIT : integer := 4;
constant RES_BIT : integer := 5;
constant CMD_TYPE_BIT : integer := 6;
constant CMD_END_BIT : integer := 7;

--ROM commands
constant POWER_ON : integer := 0;
constant POWER_OFF : integer := 24;

--power regs constants
--constant DISP_STATE : integer := 3;
--constant PWR_STATE : integer := 4;
--constant RES_REG : integer := 5;
--constant VBAT_REG : integer := 6;
--constant VDD_REG : integer := 7;


type state_t is (init0, start, cmd0, cmd1, cmd2, cmd3, cmd4, cmd5, cmd6, data0, data1, data2, data3, data4, data5);
signal state : state_t;

signal cmd_data_reg : std_logic_vector(7 downto 0);
signal sel : std_logic;

signal vdd_reg : std_logic := '1';
signal vbat_reg : std_logic := '1';
signal res_reg : std_logic := '1';
signal pwr_state : std_logic := '0';
signal disp_state : std_logic := '0';

begin
dc <= sel;
wr_data_sel <= sel;

vdd <= vdd_reg;
vbat <= vbat_reg;
res <= res_reg;

msa : process(clk, rst)
begin
if clk'event and clk = '1' then
    if rst = '1' then
        state <= init0;
        cmd_rst <= '0';
        addr_offset <= (others => '0');
        cmd_inc <= '0';
    else
        case state is
            when init0 =>
               if pwr_state = '0' then
                    state <= cmd0;
                    cmd_rst <= '1';
                    addr_offset <= std_logic_vector(to_unsigned(POWER_ON,9));
                    cmd_inc <= '0';
                else
                    state <= cmd6;
                    cmd_rst <= '0';
                    addr_offset <= (others => '0');
                    cmd_inc <= '0';
                end if;
                 
            when start =>
                if pbs(PWR_TOGGLE) = '1' then
                    state <= cmd0;
                    cmd_rst <= '1';
                    if pwr_state = '0' then
                        addr_offset <= std_logic_vector(to_unsigned(POWER_ON,9));
                    else
                        addr_offset <= std_logic_vector(to_unsigned(POWER_OFF,9));
                    end if;
                    cmd_inc <= '0';
                else
                    if pwr_state = '0' then
                        state <= start;
                        cmd_rst <= '0';
                        addr_offset <= (others => '0');
                        cmd_inc <= '0';
                    else
                        state <= data0;
                        cmd_rst <= '1';
                        addr_offset <= (others => '0');
                        cmd_inc <= '0';
                    end if;
                end if;
            when cmd0 =>
                state <= cmd1;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when cmd1 =>
                state <= cmd2;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when cmd2 =>
                state <= cmd3;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when cmd3 =>
                state <= cmd4;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when cmd4 =>
                if spi_ready = '1' and delay_cnt_done = '1' then
                    if cmd_data_reg(CMD_END_BIT) = '1' then
                        state <= cmd6;
                        cmd_rst <= '0';
                        addr_offset <= (others => '0');
                        cmd_inc <= '0';
                    else
                        state <= cmd5;
                        cmd_rst <= '0';
                        addr_offset <= (others => '0');
                        cmd_inc <= '1';
                    end if;
                else
                    state <= cmd4;
                    cmd_rst <= '0';
                    addr_offset <= (others => '0');
                    cmd_inc <= '0';
                end if;
            when cmd5 =>
                state <= cmd1;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when cmd6 =>
                if pbs(PWR_TOGGLE) = '1' then
                    state <= cmd6;
                else
                    state <= start;
                end if;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when data0 =>
                state <= data1;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when data1 =>
                state <= data2;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when data2 =>
                state <= data3;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when data3 =>
                state <= data4;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when data4 =>
                if spi_ready = '1' and delay_cnt_done = '1' then
                    if cmd_max = '1' then
                        state <= start;
                        cmd_rst <= '0';
                        addr_offset <= (others => '0');
                        cmd_inc <= '0';
                    else
                        state <= data5;
                        cmd_rst <= '0';
                        addr_offset <= (others => '0');
                        cmd_inc <= '1';
                    end if;
                else
                    state <= data4;
                    cmd_rst <= '0';
                    addr_offset <= (others => '0');
                    cmd_inc <= '0';
                end if;
            when data5 =>
                state <= data1;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
            when others =>
                state <= cmd6;
                cmd_rst <= '0';
                addr_offset <= (others => '0');
                cmd_inc <= '0';
        end case;
    end if;
end if;
end process;

input_reg : process(clk, rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            cmd_data_reg <= (others => '0');
        else
            if state = cmd2 then
                cmd_data_reg <= cmd_data;
            else
                cmd_data_reg <= cmd_data_reg;
            end if;
        end if;
    end if;
end process;

sel_reg : process(clk, rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            sel <= '0';
        else
            if state = start then
                if pbs(PWR_TOGGLE) = '1' then
                    sel <= '0';
                else
                    sel <= '1';
                end if;
            else
                sel <= sel;
            end if;
        end if;
    end if;
end process;

handshakes : process(clk, rst)      --spi_valid and delay_load
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            spi_valid <= '0';
            delay_load <= '0';
        else
            if state = cmd2 then
                spi_valid <= cmd_data(CMD_TYPE_BIT);
                delay_load <= not cmd_data(CMD_TYPE_BIT);
            elsif state = data2 then
                spi_valid <= '1';
                delay_load <= '0';
            else
                spi_valid <= '0';
                delay_load <= '0';
            end if;
        end if;
    end if;
end process;

pwr_regs_proc : process(clk)
begin
    if clk'event and clk = '1' then
        if state = init0 then
            if pwr_state = '0' then
                pwr_state <= '1';
            else
                pwr_state <= '0';
            end if;
            vdd_reg <= vdd_reg;
            vbat_reg <= vbat_reg;
            res_reg <= res_reg;
        elsif state = start then
            if pbs(PWR_TOGGLE) = '1' then
                pwr_state <= not pwr_state;
            else
                pwr_state <= pwr_state;
            end if;
            vdd_reg <= vdd_reg;
            vbat_reg <= vbat_reg;
            res_reg <= res_reg;
        elsif state = cmd2 then
            vdd_reg <= (cmd_data_reg(VDD_SET_BIT) and cmd_data_reg(VDD_BIT))
                                        or (not cmd_data_reg(VDD_SET_BIT) and vdd_reg);
            vbat_reg <= (cmd_data_reg(VBAT_SET_BIT) and cmd_data_reg(VBAT_BIT))
                                        or (not cmd_data_reg(VBAT_SET_BIT) and vbat_reg);
            res_reg <= (cmd_data_reg(RES_SET_BIT) and cmd_data_reg(RES_BIT))
                                        or (not cmd_data_reg(RES_SET_BIT) and res_reg);
            pwr_state <= pwr_state;
        else
            vdd_reg <= vdd_reg;
            vbat_reg <= vbat_reg;
            res_reg <= res_reg;
            pwr_state <= pwr_state;
        end if;
       
    end if;
end process;

end Behavioral;
