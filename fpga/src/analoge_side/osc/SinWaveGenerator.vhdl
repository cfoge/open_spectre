--   ____  _____  ______ _   _         _____ _____  ______ _____ _______ _____  ______ 
--  / __ \|  __ \|  ____| \ | |       / ____|  __ \|  ____/ ____|__   __|  __ \|  ____|
-- | |  | | |__) | |__  |  \| |      | (___ | |__) | |__ | |       | |  | |__) | |__   
-- | |  | |  ___/|  __| | . ` |       \___ \|  ___/|  __|| |       | |  |  _  /|  __|  
-- | |__| | |    | |____| |\  |       ____) | |    | |___| |____   | |  | | \ \| |____ 
--  \____/|_|    |______|_| \_|      |_____/|_|    |______\_____|  |_|  |_|  \_\______|
--                               ______                                                
--                              |______|      
-- Create Date: 2023
-- Created by: Rob D Jordan
-- Notes: Sinewave ROM should live somewhere cleaner.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SinWaveGenerator is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        freq : in STD_LOGIC_VECTOR(9 downto 0);
        sync_sel : in STD_LOGIC_VECTOR(1 downto 0);
        sync_plus : in STD_LOGIC;
        sync_minus : in STD_LOGIC;
        dist_level      : in STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- distortion wave level
        sin_out : out STD_LOGIC_VECTOR(11 downto 0);
        square_out : out STD_LOGIC
    );
end SinWaveGenerator;

architecture Behavioral of SinWaveGenerator is
    signal counter, counterB : STD_LOGIC_VECTOR(13 downto 0) := (others => '0');
    signal scaled_freq : STD_LOGIC_VECTOR(13 downto 0) := (others => '0');

    signal phase_accumulator,phase_accumulatorB:  integer range 0 to 180;--unsigned(13 downto 0) := (others => '0');  -- Use 12 bits for phase accumulator
    signal rom_address, rom_address_dist : integer range 0 to 180;
    signal sine_table, sine_table_dist,sin_table_xmod : STD_LOGIC_VECTOR(11 downto 0);
    signal sine_table_summed, sine_table_summed_limited : STD_LOGIC_VECTOR(12 downto 0);
    signal square_i : STD_LOGIC := '0';
    signal sync_edge : STD_LOGIC := '0';
    signal sync_in : STD_LOGIC := '0';
    signal dist_freq : STD_LOGIC_VECTOR(13 downto 0) := (others => '1');
    
      signal atten_val    : unsigned(11 downto 0);
  signal atten_val_d    : unsigned(11 downto 0);
    
    --
    
    signal attenuated_out   : STD_LOGIC_VECTOR(11 downto 0);

    type ROM is array (0 to 360) of STD_LOGIC_VECTOR(11 downto 0); -- i think this only needs to be 180
    constant sine_rom : ROM := (
"011111111111",
"100001000110",
"100010001101",
"100011010100",
"100100011011",
"100101100010",
"100110101000",
"100111101110",
"101000110011",
"101001110111",
"101010111011",
"101011111101",
"101100111111",
"101110000000",
"101111000000",
"101111111110",
"110000111011",
"110001110111",
"110010110010",
"110011101011",
"110100100010",
"110101011000",
"110110001100",
"110110111111",
"110111110000",
"111000011111",
"111001001100",
"111001110111",
"111010100000",
"111011000110",
"111011101011",
"111100001110",
"111100101110",
"111101001101",
"111101101000",
"111110000010",
"111110011001",
"111110101110",
"111111000001",
"111111010001",
"111111011110",
"111111101010",
"111111110010",
"111111111001",
"111111111100",
"111111111110",
"111111111100",
"111111111001",
"111111110010",
"111111101010",
"111111011110",
"111111010001",
"111111000001",
"111110101110",
"111110011001",
"111110000010",
"111101101000",
"111101001101",
"111100101110",
"111100001110",
"111011101011",
"111011000110",
"111010100000",
"111001110111",
"111001001100",
"111000011111",
"110111110000",
"110110111111",
"110110001100",
"110101011000",
"110100100010",
"110011101011",
"110010110010",
"110001110111",
"110000111011",
"101111111110",
"101111000000",
"101110000000",
"101100111111",
"101011111101",
"101010111011",
"101001110111",
"101000110011",
"100111101110",
"100110101000",
"100101100010",
"100100011011",
"100011010100",
"100010001101",
"100001000110",
"100000000010",
"011110111010",
"011101110011",
"011100101100",
"011011100101",
"011010011110",
"011001011000",
"011000010010",
"010111001101",
"010110001001",
"010101000101",
"010100000011",
"010011000001",
"010010000000",
"010001000000",
"010000000010",
"001111000101",
"001110001001",
"001101001110",
"001100010101",
"001011011110",
"001010101000",
"001001110100",
"001001000001",
"001000010000",
"000111100001",
"000110110100",
"000110001001",
"000101100000",
"000100111010",
"000100010101",
"000011110010",
"000011010010",
"000010110011",
"000010011000",
"000001111110",
"000001100111",
"000001010010",
"000000111111",
"000000101111",
"000000100010",
"000000010110",
"000000001110",
"000000000111",
"000000000100",
"000000000010",
"000000000100",
"000000000111",
"000000001110",
"000000010110",
"000000100010",
"000000101111",
"000000111111",
"000001010010",
"000001100111",
"000001111110",
"000010011000",
"000010110011",
"000011010010",
"000011110010",
"000100010101",
"000100111010",
"000101100000",
"000110001001",
"000110110100",
"000111100001",
"001000010000",
"001001000001",
"001001110100",
"001010101000",
"001011011110",
"001100010101",
"001101001110",
"001110001001",
"001111000101",
"010000000010",
"010001000000",
"010010000000",
"010011000001",
"010100000011",
"010101000101",
"010110001001",
"010111001101",
"011000010010",
"011001011000",
"011010011110",
"011011100101",
"011100101100",
"011101110011",
"011110111010",
"100000000001",
"100000100010",
"100001101010",
"100010110001",
"100011111000",
"100100111111",
"100110000101",
"100111001011",
"101000010000",
"101001010101",
"101010011001",
"101011011100",
"101100011110",
"101101100000",
"101110100000",
"101111011111",
"110000011101",
"110001011001",
"110010010101",
"110011001110",
"110100000111",
"110100111101",
"110101110011",
"110110100110",
"110111011000",
"111000000111",
"111000110101",
"111001100001",
"111010001011",
"111010110011",
"111011011001",
"111011111101",
"111100011110",
"111100111110",
"111101011011",
"111101110110",
"111110001110",
"111110100100",
"111110111000",
"111111001001",
"111111011000",
"111111100100",
"111111101110",
"111111110110",
"111111111011",
"111111111101",
"111111111101",
"111111111011",
"111111110110",
"111111101110",
"111111100100",
"111111011000",
"111111001001",
"111110111000",
"111110100100",
"111110001110",
"111101110110",
"111101011011",
"111100111110",
"111100011110",
"111011111101",
"111011011001",
"111010110011",
"111010001011",
"111001100001",
"111000110101",
"111000000111",
"110111011000",
"110110100110",
"110101110011",
"110100111101",
"110100000111",
"110011001110",
"110010010101",
"110001011001",
"110000011101",
"101111011111",
"101110100000",
"101101100000",
"101100011110",
"101011011100",
"101010011001",
"101001010101",
"101000010000",
"100111001011",
"100110000101",
"100100111111",
"100011111000",
"100010110001",
"100001101010",
"100000100010",
"011111011110",
"011110010110",
"011101001111",
"011100001000",
"011011000001",
"011001111011",
"011000110101",
"010111110000",
"010110101011",
"010101100111",
"010100100100",
"010011100010",
"010010100000",
"010001100000",
"010000100001",
"001111100011",
"001110100111",
"001101101011",
"001100110010",
"001011111001",
"001011000011",
"001010001101",
"001001011010",
"001000101000",
"000111111001",
"000111001011",
"000110011111",
"000101110101",
"000101001101",
"000100100111",
"000100000011",
"000011100010",
"000011000010",
"000010100101",
"000010001010",
"000001110010",
"000001011100",
"000001001000",
"000000110111",
"000000101000",
"000000011100",
"000000010010",
"000000001010",
"000000000101",
"000000000011",
"000000000011",
"000000000101",
"000000001010",
"000000010010",
"000000011100",
"000000101000",
"000000110111",
"000001001000",
"000001011100",
"000001110010",
"000010001010",
"000010100101",
"000011000010",
"000011100010",
"000100000011",
"000100100111",
"000101001101",
"000101110101",
"000110011111",
"000111001011",
"000111111001",
"001000101000",
"001001011010",
"001010001101",
"001011000011",
"001011111001",
"001100110010",
"001101101011",
"001110100111",
"001111100011",
"010000100001",
"010001100000",
"010010100000",
"010011100010",
"010100100100",
"010101100111",
"010110101011",
"010111110000",
"011000110101",
"011001111011",
"011011000001",
"011100001000",
"011101001111",
"011110010110",
"011111011110"
    );

begin

    scaled_freq <= freq & "0000";
    dist_freq <= "00" & freq & "11";

    process(clk, reset, sync_in)
    begin
        if reset = '1' then
            counter <= (others => '0');
            counterB <= (others => '0');
            phase_accumulator <= 0;
            phase_accumulatorB <= 0;
            sync_edge <= '0';
        elsif rising_edge(clk) then
        
            if sync_sel = "00" then
                sync_in <= '0';
            elsif sync_sel = "01" then
                sync_in <= sync_plus;
            elsif sync_sel = "10" then 
                sync_in <= sync_minus;
            end if;
        
            if sync_in = '1' and sync_edge = '0' then
                sync_edge <= '1';
                counter <= (others => '0');
                phase_accumulator <= 0;
            else
                sync_edge <= sync_in;
                counter <= counter + 1;
                counterB <= counterB + 1;
                if rom_address > 90 then
                    square_i <= '1';
                    else 
                    square_i <= '0';
                    end if; 
                if counter = scaled_freq then
                    counter <= (others => '0');
                    phase_accumulator <= phase_accumulator + 1;
--                    if phase_accumulator = "11111111111111" then  -- Adjust the limit for 12 bits
--                        phase_accumulator <= (others => '0');
--                    end if;                    
                end if;
                if counterB = dist_freq then
                    counterB <= (others => '0');
                    phase_accumulatorB <= phase_accumulatorB + 1;
--                    if phase_accumulatorB = "11111111111111" then  -- Adjust the limit for 12 bits
--                        phase_accumulatorB <= (others => '0');
--                    end if;                    
                end if;
                
            end if;
        end if;
    end process;


   
    
process(clk) -- ff the output to lower the logic levels in the acumulator path
begin
  if rising_edge(clk) then
      -- ROM lookup
    rom_address <= phase_accumulator;-- to_integer(unsigned(phase_accumulator)) mod 180 ; -- how manny entries are ther in my sin table?? 180 or 360
    -- Distort wave lookup
    rom_address_dist <= phase_accumulatorB;-- to_integer(unsigned(phase_accumulatorB)) mod 180 ;
    -- Create the full sine wave using symmetry
    sine_table <= sine_rom(rom_address);
    -- Create the distortion sinwave
    sine_table_dist <= sine_rom(rom_address_dist); -- needs to have a amplitude control to mix the level
    end if;
    end process;
    
process(clk) -- modulate the sinwave by the attenuated other sinwave
  variable mult_resultA : unsigned(19 downto 0); -- 12+8
  variable mult_resultB : unsigned(23 downto 0); -- 12+8
--  variable atten_val    : unsigned(11 downto 0);
--  variable atten_val_d    : unsigned(11 downto 0);

begin
  if rising_edge(clk) then
    -- Step 1: attenuate distortion
    mult_resultA := unsigned(sine_table_dist) * (unsigned(dist_level));  -- 12 x 8
    atten_val <= mult_resultA(19 downto 8);  -- keep 12 bits

    -- Save result
--    attenuated_out <= std_logic_vector(atten_val);
    atten_val_d <= atten_val; 

    -- Step 2: use it to attenuate main sine
    mult_resultB := unsigned(sine_table) * (4095 - atten_val_d);
    sin_table_xmod <= std_logic_vector(mult_resultB(23 downto 12));
  end if;
end process;
    
--    process(clk) 
--        begin
--        if rising_edge(clk) then
--        sine_table_summed <= ('0'& sine_table) + ('0' & attenuated_out); 

--        if sine_table_summed(12) = '1' then
--            sine_table_summed_limited <= (others => '1');
--         else
--            sine_table_summed_limited <= sine_table_summed;
--         end if;
         
--          end if;
        
--        end process;

    sin_out <= sin_table_xmod;
    square_out <= square_i;

end Behavioral;
