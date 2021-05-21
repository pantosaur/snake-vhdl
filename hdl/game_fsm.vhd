--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_fsm is
port(
    rst : in std_logic;
    clk : in std_logic;
    go : in std_logic;
    control_in : in std_logic_vector(3 downto 0);
    control_out : out std_logic_vector(1 downto 0);
    snake_reset : out std_logic;
    snake_size_inc : out std_logic;
    snake_ready : in std_logic;
    snake_valid : out std_logic;
    apple_ready : in std_logic;
    apple_valid : out std_logic;
    col_ready : in std_logic;
    col_start : out std_logic;
    collision: in std_logic_vector(1 downto 0);
    snake_size: in std_logic_vector(5 downto 0);
    game_mode : out std_logic_vector(1 downto 0)
);
end game_fsm;

architecture Behavioral of game_fsm is

--constants for game modes
constant WELCOME : integer := 0;
constant GAME : integer := 1;
constant LOSS : integer := 2;
constant WIN : integer := 3;

--constants for directions
constant DOWN : integer := 0;
constant LEFT : integer := 1;
constant RIGHT : integer := 2;
constant UP : integer := 3;

--constants for collision types
constant NONE : integer := 0;
constant WALL : integer := 1;
constant TAIL : integer := 2;
constant APPLE : integer := 3;

--constant for maximum snake length (victory)
constant SNAKEWIN : integer := 12;

type state_T is (welcome_state, release1, wait_first_go, snake_first_hs, snake_wait, apple_hs, apple_wait, col_hs, col_wait, wait_go, snake_hs, win_state, lose_state, release2, release3, release4, release5);
signal state : state_T;

signal eaten_apple_r : std_logic; --register that keeps last apple collision

signal control_out_r : std_logic_vector(1 downto 0);

begin

control_out <= control_out_r;
game_mode <=    std_logic_vector(to_unsigned(WELCOME,2)) when state = welcome_state or state = release1 or state = wait_first_go else
                std_logic_vector(to_unsigned(LOSS,2)) when state = lose_state or state = release3 or state = release5 else
                std_logic_vector(to_unsigned(WIN,2)) when state = win_state or state = release2 or state = release4 else
                std_logic_vector(to_unsigned(GAME,2));
                
snake_valid <=  '1' when state = snake_first_hs or state = snake_hs else
                '0';
                
snake_reset <=  '1' when state = snake_first_hs else
                '0';
                
snake_size_inc <=   '1' when state = snake_hs and eaten_apple_r = '1' else
                    '0';
                    
apple_valid <=  '1' when state = apple_hs else
                '0';
                
col_start <=    '1' when state = col_hs else
                '0';

control_in_proc: process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            control_out_r <= std_logic_vector(to_unsigned(DOWN,2));
        else
            if state = welcome_state or state = release1 then
                control_out_r <= std_logic_vector(to_unsigned(RIGHT,2));
            else
                case control_in is
                    when "0001" =>
                        control_out_r <= std_logic_vector(to_unsigned(DOWN,2));
                    when "0010" =>
                        control_out_r <= std_logic_vector(to_unsigned(LEFT,2));
                    when "0100" =>
                        control_out_r <= std_logic_vector(to_unsigned(RIGHT,2));
                    when "1000" =>
                        control_out_r <= std_logic_vector(to_unsigned(UP,2));
                    when others =>
                        control_out_r <= control_out_r;
                end case;
            end if;
        end if;
    end if;
end process;

game_fsm_proc : process(clk,rst)
begin
    if clk'event and clk = '1' then
        if rst = '1' then
            state <= welcome_state;
            eaten_apple_r <= '0';
        else
            case state is
                when welcome_state =>
                    if control_in /= "0000" then
                        state <= release1;
                        eaten_apple_r <= '0';
                    else
                        state <= welcome_state;
                        eaten_apple_r <= '0';
                    end if;
                when release1 =>
                    if control_in = "0000" then
                        state <= wait_first_go;
                        eaten_apple_r <= '0';
                    else
                        state <= release1;
                        eaten_apple_r <= '0';
                    end if;
                when wait_first_go =>
                    if go = '1' then
                        state <= snake_first_hs;
                        eaten_apple_r <= '0';
                    else
                        state <= wait_first_go;
                        eaten_apple_r <= '0';
                    end if;
                when snake_first_hs =>
                    state <= snake_wait;
                    eaten_apple_r <= eaten_apple_r;
                when snake_wait =>
                    if snake_ready = '1' then
                        state <= col_hs;
                        eaten_apple_r <= eaten_apple_r;
                    else
                        state <= snake_wait;
                        eaten_apple_r <= eaten_apple_r;
                    end if;
                when apple_hs =>
                    state <= apple_wait;
                    eaten_apple_r <= eaten_apple_r;
                when apple_wait =>
                    if apple_ready = '1' then
                        state <= wait_go;
                        eaten_apple_r <= eaten_apple_r;
                    else
                        state <= apple_wait;
                        eaten_apple_r <= eaten_apple_r;
                    end if;
                when col_hs =>
                    state <= col_wait;
                    eaten_apple_r <= eaten_apple_r;
                when col_wait =>
                    if col_ready = '1' then
                        if snake_size = std_logic_vector(to_unsigned(SNAKEWIN,6)) then
                            state <= release4;
                            eaten_apple_r <= '0';
                        elsif collision = std_logic_vector(to_unsigned(WALL,2)) or collision = std_logic_vector(to_unsigned(TAIL,2)) then
                            state <= release5;
                            eaten_apple_r <= '0';
                        else
                            if collision = std_logic_vector(to_unsigned(APPLE,2)) then
                                state <= apple_hs;
                                eaten_apple_r <= '1';
                            else
                                state <= wait_go;
                                eaten_apple_r <= '0';
                            end if;
                        end if;
                    else
                        state <= col_wait;
                        eaten_apple_r <= eaten_apple_r;
                    end if;
                when wait_go =>
                    if go = '1' then
                        state <= snake_hs;
                        eaten_apple_r <= eaten_apple_r;
                    else
                        state <= wait_go;
                        eaten_apple_r <= eaten_apple_r;
                    end if;
                when snake_hs =>
                    state <= snake_wait;
                    eaten_apple_r <= eaten_apple_r;
                when win_state =>
                    if control_in /= "0000" then
                        state <= release2;
                        eaten_apple_r <= '0';
                    else
                        state <= win_state;
                        eaten_apple_r <= '0';
                    end if;
                when lose_state =>
                    if control_in /= "0000" then
                        state <= release3;
                        eaten_apple_r <= '0';
                    else
                        state <= lose_state;
                        eaten_apple_r <= '0';
                    end if;
                when release2 =>
                    if control_in = "0000" then
                        state <= welcome_state;
                        eaten_apple_r <= '0';
                    else
                        state <= release2;
                        eaten_apple_r <= '0';
                    end if;
                when release3 =>
                    if control_in = "0000" then
                        state <= welcome_state;
                        eaten_apple_r <= '0';
                    else
                        state <= release3;
                        eaten_apple_r <= '0';
                    end if;
                when release4 =>
                    if control_in = "0000" then
                        state <= win_state;
                        eaten_apple_r <= '0';
                    else
                        state <= release4;
                        eaten_apple_r <= '0';
                    end if;
                when release5 =>
                    if control_in = "0000" then
                        state <= lose_state;
                        eaten_apple_r <= '0';
                    else
                        state <= release5;
                        eaten_apple_r <= '0';
                    end if;
                when others =>
                    state <= welcome_state;
                    eaten_apple_r <= '0';
            end case;
        end if;
    end if;
end process;


----USED FOR TESTING
--game_fsm_proc : process(clk,rst)
--begin
--    if clk'event and clk = '1' then
--        if rst = '1' then
--           snake_valid <= '0';
--        else
--            if go = '1' then
--                if snake_ready = '1' then
--                    snake_valid <= '1';
--                else
--                    snake_valid <= '0';         ---should always be ready!
--                end if;
--            else
--                snake_valid <= '0';
--            end if;
                
--        end if;
--    end if;
--end process;

--game_fsm_proc2 : process(clk,rst)
--begin
--    if clk'event and clk = '1' then
--        if rst = '1' then
--           apple_valid <= '0';
--        else
--            if go = '1' then
--                if apple_ready = '1' then
--                    apple_valid <= '1';
--                else
--                    apple_valid <= '0';         ---should always be ready!
--                end if;
--            else
--                apple_valid <= '0';
--            end if;
                
--        end if;
--    end if;
--end process;

end Behavioral;
