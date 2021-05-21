--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity display_top is
    port(
    rst : in std_logic;
    clk : in std_logic;
    
    control : in std_logic_vector(4 downto 0);
    
    oled_vdd : out std_logic;
    oled_vbat : out std_logic;
    oled_res : out std_logic;
    
    oled_dc : out std_logic;
    oled_sclk : out std_logic;
    oled_sdin : out std_logic;
    
    fb_clk_wr : in std_logic;
    fb_we : in std_logic;
    fb_addr_wr : in std_logic_vector(8 downto 0);
    fb_data_wr : in std_logic_vector(7 downto 0)
    );
end display_top;

architecture Behavioral of display_top is

type ROM_cmd_t is array (0 to 511) of std_logic_vector(63 downto 0);
constant cmd_mem : ROM_cmd_t := (
X"ffffff0100138800", X"ffffff40000000AE", X"ffffff1000138800", X"ffffff3000138800", X"ffffff400000008D", X"ffffff4000000014", X"ffffff40000000D9", X"ffffff40000000F1",         --power on sequence
X"ffffff0407A12000", X"ffffff4000000081", X"ffffff400000000F", X"ffffff40000000A0", X"ffffff40000000C0", X"ffffff40000000DA", X"ffffff4000000000", X"ffffff40000000AF",
--X"ffffff0100000200", X"ffffff40000000AE", X"ffffff1000000200", X"ffffff3000000200", X"ffffff400000008D", X"ffffff4000000014", X"ffffff40000000D9", X"ffffff40000000F1",       --simulation power on
--X"ffffff0400000200", X"ffffff4000000081", X"ffffff400000000F", X"ffffff40000000A0", X"ffffff40000000C0", X"ffffff40000000DA", X"ffffff4000000000", X"ffffffC0000000AF",
X"ffffff4000000020", X"ffffffC000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff40000000AE", X"ffffff0C07A12000", X"ffffff8300138800", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",         --power off sequence           
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000",
X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000", X"ffffff0000000000"
);

type RAM_2p_T is array(511 downto 0) of std_logic_vector(7 downto 0);
signal RAM_2p : RAM_2p_T;

component display_fsm
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
end component;
component spi_master
    port(
    clk : in std_logic;
    
    ready : out std_logic;
    valid : in std_logic;
    data : in std_logic_vector(7 downto 0);
    
    sclk : out std_logic;
    sdin : out std_logic
    );
end component;


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

component delay_cnt is
    port(
        clk : in std_logic;
        rst : in std_logic;
        delay_load : in std_logic;
        cnt_out : out std_logic_vector(18 downto 0);
        cmd_delay : in std_logic_vector(18 downto 0)
    );
end component;




signal wr_data_sel_top : std_logic;

signal spi_ready_top : std_logic;
signal spi_valid_top : std_logic;
signal spi_data_top : std_logic_vector(7 downto 0);


signal cmd_inc_top : std_logic;
signal cmd_rst_top : std_logic;
signal addr_offset_top : std_logic_vector(8 downto 0);   
signal cmd_max_top : std_logic;
signal addr_count_top : std_logic_vector(8 downto 0);
signal cmd_data_top : std_logic_vector(7 downto 0);

signal delay_load_top : std_logic;
signal delay_cnt_done_top : std_logic;




signal cmd_delay_top : std_logic_vector(18 downto 0);
signal cnt_out_top : std_logic_vector(18 downto 0);

signal cmd_mem_data : std_logic_vector(63 downto 0);
signal cmd_mem_spi_data : std_logic_vector(7 downto 0);
signal fb_mem_data: std_logic_vector(7 downto 0);

signal pbs_in : std_logic_vector(4 downto 0);


begin


display_fsm_0 : display_fsm
port map(
    clk => clk,
    rst => rst,
    dc => oled_dc,
    wr_data_sel => wr_data_sel_top,
    spi_ready => spi_ready_top,
    spi_valid => spi_valid_top,
    pbs => pbs_in,
    cmd_inc => cmd_inc_top,
    cmd_rst => cmd_rst_top,
    addr_offset => addr_offset_top,
    cmd_max => cmd_max_top,
    delay_load => delay_load_top,
    delay_cnt_done => delay_cnt_done_top,
    cmd_data => cmd_data_top,
    vdd => oled_vdd,
    vbat => oled_vbat,
    res => oled_res
);
spi_master_0 : spi_master
port map(
    clk => clk,
    ready => spi_ready_top,
    valid => spi_valid_top,
    data => spi_data_top,
    sclk => oled_sclk,
    sdin => oled_sdin
);

cmd_addr_inst_0 : cmd_addr
port map(
    clk => clk,
    rst => rst,
    cmd_inc => cmd_inc_top,
    cmd_rst => cmd_rst_top,
    addr_offset => addr_offset_top,
    cmd_max => cmd_max_top,
    addr_count => addr_count_top    
);

delay_cnt_inst_0 : delay_cnt
port map(
    clk => clk,
    rst => rst,
    delay_load => delay_load_top,
    cnt_out => cnt_out_top,
    cmd_delay => cmd_delay_top
);


delay_cnt_done_top <= '1' when unsigned(cnt_out_top) = 0 else '0';

spi_data_mux : process(cmd_mem_spi_data, fb_mem_data, wr_data_sel_top)
begin
    if wr_data_sel_top = '0' then
        spi_data_top <= cmd_mem_spi_data;
    else
        spi_data_top <= fb_mem_data;
    end if;
end process;


ROM_proc : process(clk)
begin
    if clk'event and clk = '1' then
        cmd_mem_data <= cmd_mem(to_integer(unsigned(addr_count_top)));
    end if;
end process;
ram_sync_p1: process(clk)
begin
    if clk'event and clk = '1' then
        fb_mem_data <= RAM_2p(to_integer(unsigned(addr_count_top)));
    end if;
end process;
ram_sync_p2: process(fb_clk_wr)
begin
    if fb_clk_wr'event and fb_clk_wr = '1' then
        if fb_we = '1' then
            RAM_2p(to_integer(unsigned(fb_addr_wr))) <= fb_data_wr;
        end if;
    end if;
end process;

cmd_delay_top <= cmd_mem_data(26 downto 8);
cmd_data_top <= cmd_mem_data(39 downto 32);
cmd_mem_spi_data <= cmd_mem_data(7 downto 0);

pbs_in <= control;

end Behavioral;
