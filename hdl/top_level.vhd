--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity top_level is
    port(
    rst_n : in std_logic;
    clk_100mhz : in std_logic;
    
    pbs: in std_logic_vector(4 downto 0);
    leds_o: out std_logic_vector(7 downto 0);
    
    oled_vdd : out std_logic;
    oled_vbat : out std_logic;
    oled_res : out std_logic;
    
    oled_dc : out std_logic;
    oled_sclk : out std_logic;
    oled_sdin : out std_logic
    );
end top_level;

architecture Behavioral of top_level is

component clk_gen
port(
    clk_in : in std_logic;
    clk_game : out std_logic;
    clk_display : out std_logic;
    locked : out std_logic;
    locked2 : out std_logic
);
end component;

component debouncer is	
    Port ( 
        rst : in std_logic;
        clk : in std_logic;
        b_i : in std_logic;
        b_o: out std_logic
    );
end component;

component clk_div_2000 is	
    Port ( 
        rst : in std_logic;
        clk_i : in std_logic;
        clk_o: out std_logic
    );
end component;

component sync_io is	
   generic
        (
        IO_LOGIC : std_logic := '1'-- 1=POSITIVE 0=NEGATIVE
        );
    Port ( 
        rst : in std_logic;
        clk_front : in std_logic;
        clk_back : in std_logic;
        s_i : in std_logic;
        s_o : out std_logic
    );
end component;

component game_top is
    port(
    rst : in std_logic;
    clk : in std_logic;
    ram_we : out std_logic;
    ram_addr : out std_logic_vector(8 downto 0);
    ram_data : out std_logic_vector(7 downto 0);
    user_control : in std_logic_vector(3 downto 0)
    );
end component;

component display_top is
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
end component;

signal clk_display : std_logic;
signal clk_2_5khz: std_logic;
signal clk_game : std_logic;
signal rst_sys : std_logic;
signal locked, locked2 : std_logic;

--fb write signals
signal fb_we : std_logic;
signal fb_addr_wr : std_logic_vector(8 downto 0);
signal fb_data_wr : std_logic_vector(7 downto 0);

signal hb_cnt : std_logic_vector(23 downto 0);

signal pbs_deb : std_logic_vector(4 downto 0);
signal pbs_sync : std_logic_vector(4 downto 0);

begin

inst_game: game_top
port map
(
    clk => clk_game,
    rst => rst_sys,
    ram_we => fb_we,
    ram_addr => fb_addr_wr,
    ram_data => fb_data_wr,
    --user_control => pbs(4 downto 1)
    user_control => pbs_sync(4 downto 1)
);

inst_display: display_top 
port map
(
    rst => rst_sys,
    clk => clk_display,
    --control => pbs(4 downto 0),
    control => pbs_sync(4 downto 0),
    oled_vdd => oled_vdd,
    oled_vbat => oled_vbat,
    oled_res => oled_res,
    oled_dc => oled_dc,
    oled_sclk => oled_sclk,
    oled_sdin => oled_sdin,
    fb_clk_wr => clk_game,
    fb_we => fb_we,
    fb_addr_wr => fb_addr_wr,
    fb_data_wr => fb_data_wr
);


inst_clk_gen: clk_gen
port map(
    clk_in => clk_100mhz,
    clk_game => clk_game,
    clk_display => clk_display,
    locked => locked,
    locked2 => locked2
);

GEN_PB_DEB:for I in 0 to 4 generate
    deb_inst: debouncer
    port map(
        rst => rst_sys,
        clk => clk_2_5khz,
        b_i => pbs(I),
        b_o => pbs_deb(I)
    );
end generate;

GEN_PB_SYNC:for I in 0 to 4 generate
    sync_inst: sync_io
    generic map(
        IO_LOGIC => '1'
    )
    port map
    (
        rst => rst_sys,
        clk_front => clk_2_5khz,
        clk_back =>  clk_display,
        s_i => pbs_deb(I),
        s_o => pbs_sync(I)
    );

end generate;
      

inst_clk_div_2000: clk_div_2000
port map(
    rst => rst_sys,
    clk_i => clk_display,
    clk_o => clk_2_5khz
);

rst_sys <= (not rst_n) or not locked or not locked2;

heartbeat: process(clk_display, rst_sys)
begin
    if clk_display'event and clk_display = '1' then
        if rst_sys = '1' then
            hb_cnt <= (others => '0');
        else
            hb_cnt <= std_logic_vector(unsigned(hb_cnt) + 1);
        end if;
    end if;
end process;


leds_o <= "00000000" when hb_cnt(22) = '0' else "10000000";

end Behavioral;
