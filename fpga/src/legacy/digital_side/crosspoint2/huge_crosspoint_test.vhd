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
-- Module Name: huge_crospoint_test - Behavioral

-- Description: Curently replaced by OR marix because there was a limit of x pins per row and that was going to be confusing to users.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use ieee.numeric_std.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity huge_crospoint_test is
    Port ( matrix_in : in STD_LOGIC_VECTOR (64 downto 0);
           in_addr  : in STD_LOGIC_VECTOR (5 downto 0);
           in_mux   : in STD_LOGIC_VECTOR (5 downto 0);
           clk        : in std_logic ;
           rst        : in std_logic ;
           load        : in std_logic ;
           latch        : in std_logic ;
           cs        : in std_logic ;
           matrix_out : out STD_LOGIC_VECTOR (64 downto 0));
end huge_crospoint_test;

architecture Behavioral of huge_crospoint_test is

 function mux_n (A,B: in std_logic_vector) return std_logic is
  begin
      return A(to_integer(unsigned(B)));
  end mux_n;
  
  signal latch_en, load_en, reset  : std_logic ;
  signal mux_sel_A :  STD_LOGIC_VECTOR (383 downto 0);
  signal mux_sel_latch :  STD_LOGIC_VECTOR (383 downto 0);
  signal matrix_out_A :  STD_LOGIC_VECTOR (64 downto 0);


begin

load_en  <= load and cs;
latch_en <= latch and cs;
reset    <= rst and cs;

process(clk)
    begin
       if rising_edge(clk) then
     
        if(reset = '1') then
            mux_sel_A <= (others => '0');
            --mux_sel_latch <= (others => '0'); -- this line creates multi drive
            
        elsif (load_en = '1') then
            mux_sel_A((6 * to_integer(unsigned(in_addr)) + 5)  downto 6*to_integer(unsigned(in_addr))) <= in_mux;
        end if;
        end if;
end process;
         
process(clk)
    begin
       if rising_edge(clk) then
        if(latch_en = '1' and reset = '0') then
            mux_sel_latch <= mux_sel_A;
        end if;
         end if;
    end process;

 g_GENERATE_HUGE_MATRIX_A: for ii in 0 to 63 generate
    matrix_out_A(ii) <= mux_n(matrix_in, mux_sel_latch((ii*6 + 5) downto ii*6));
  end generate g_GENERATE_HUGE_MATRIX_A;
  matrix_out_A(64) <= '0'; -- somthing about the above generate has issues with the 64th mux so ill just fix it to 0 for now
  

  matrix_out <= matrix_out_A;



end Behavioral;
