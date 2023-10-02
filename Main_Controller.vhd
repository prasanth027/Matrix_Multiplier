----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.02.2020 14:31:09
-- Design Name: 
-- Module Name: Main_Controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Main_Controller is
 Port (clk     : in  std_logic;
       reset   : in  std_logic;
       start_fetching : in  std_logic;   --- Start button 
       Ram_enablecomp : in  std_logic;   --- Completed Extracting D plication completed ack
       Rom_enablecomp : in  std_logic;
       start_operation_input : out  std_logic;  --- starts multiplication process
        start_operation_coeff : out  std_logic;
        start_operation_mul : out  std_logic;
        Matrix_mul : in  std_logic;
        matrix_out: out  std_logic;
        Ram_enable : out  std_logic;      --- Starts fetching data to RAM
        Rom_enable : out  std_logic      --- Starts fetching data to ROM   
 );
end Main_Controller;

architecture Behavioral of Main_Controller is
type state_type is (idle,enable,fetch,save_data,delay,delay2);
signal current_state, next_state : state_type;
signal count,count_next: unsigned( 3 downto 0);

begin
process(clk,reset)              -- The register process
begin
  if reset ='1' then
    current_state <= idle;
    count  <= (others => '0'); 
  elsif clk'event and clk = '1' then
    current_state <= next_state;
    count <= count_next ;
   end if;
end process;
asdd: process(current_state,count,start_fetching,Ram_enablecomp,Rom_enablecomp,Matrix_mul)
begin
 next_state <= current_state;
 Ram_enable <= '0';
 Rom_enable <= '0';
 start_operation_input <= '0';
 start_operation_coeff <= '0';
 start_operation_mul <= '0';
  count_next <= count ;
  matrix_out <= '0';
 case current_state is
 when idle =>
   if start_fetching = '1' then
     next_state <= enable;
    else 
     next_state <= idle;
     end if;
  when enable =>
       Ram_enable <= '1';
       Rom_enable <= '1';
        next_state <= fetch;  
  when fetch =>
      if Ram_enablecomp = '1' and Rom_enablecomp = '1' then
     next_state <= delay2; 
      else
        next_state <= fetch;
      end if;
    when delay2 => 
     
         next_state <= delay; 
     
    when delay =>  
       start_operation_input <= '1';
       start_operation_coeff <= '1';
       start_operation_mul <= '1';
       next_state <= save_data;
   when save_data =>
      if Matrix_mul = '1' and count < "0101" then
       matrix_out <= '1';
       count_next <= count+1;
           next_state <= idle;
         else 
       matrix_out  <= '0';
        count_next <= (others => '0');
       next_state <= save_data;
      end if;
    end case;
   end process;
end Behavioral;
