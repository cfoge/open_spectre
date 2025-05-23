--   ____  _____  ______ _   _         _____ _____  ______ _____ _______ _____  ______ 
--  / __ \|  __ \|  ____| \ | |       / ____|  __ \|  ____/ ____|__   __|  __ \|  ____|
-- | |  | | |__) | |__  |  \| |      | (___ | |__) | |__ | |       | |  | |__) | |__   
-- | |  | |  ___/|  __| | . ` |       \___ \|  ___/|  __|| |       | |  |  _  /|  __|  
-- | |__| | |    | |____| |\  |       ____) | |    | |___| |____   | |  | | \ \| |____ 
--  \____/|_|    |______|_| \_|      |_____/|_|    |______\_____|  |_|  |_|  \_\______|
--                               ______                                                
--                              |______|                                               
-- Module Name: 
-- Created: Early 2023
-- Description: 
-- Dependencies: 
-- Additional Comments: You can view the project here: https://github.com/cfoge/OPEN_SPECTRE-

-- created by   :   RD Jordan

library ieee;
use ieee.std_logic_1164.all;

entity pulse_generator_tb is
end pulse_generator_tb;

architecture behavior of pulse_generator_tb is
    signal clk : std_logic := '0';
    signal pulse_6hz : std_logic;
    signal pulse_3hz : std_logic;
    signal pulse_1_5hz : std_logic;
    signal pulse_0_6hz : std_logic;
    signal pulse_0_4hz : std_logic;
    signal pulse_0_2hz : std_logic;
begin
    -- Instantiate the pulse_generator module
    uut: entity work.pulse_generator
        generic map (
            CLOCK_FREQUENCY => 100
        )
        port map (
            clk => clk,
            pulse_6hz => pulse_6hz,
            pulse_3hz => pulse_3hz,
            pulse_1_5hz => pulse_1_5hz,
            pulse_0_6hz => pulse_0_6hz,
            pulse_0_4hz => pulse_0_4hz,
            pulse_0_2hz => pulse_0_2hz
        );
    
    -- Clock process to drive the test bench
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;
    
   
end architecture;