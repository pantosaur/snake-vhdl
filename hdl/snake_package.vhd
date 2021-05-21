--Copyright (c) 2021 Pierre A. Sauriol

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package snake_package is
    type snake is array(63 downto 0) of std_logic_vector(7 downto 0);
end package snake_package;
