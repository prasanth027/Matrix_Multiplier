----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.02.2020 13:13:51
-- Design Name: 
-- Module Name: RAM - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
Port (clk     : in  std_logic;
     reset   : in  std_logic;
     RAM_DATA :in unsigned (16 downto 0);
     write_ack :in  std_logic;
     data_input_ram :in std_logic_vector (31 downto 0);
     RYxSO_ack   : in std_logic;
     data_RAM :out unsigned (16 downto 0);
     data_out :out std_logic_vector (31 downto 0);
     CS_enable   : out  std_logic;  -- Active Low
     WE_enable   : out  std_logic;       --Active Low
     Addr   : out std_logic_vector (7 downto 0)
     );
end RAM;
architecture Behavioral of RAM is

type state_type is (write_data,read_data);
signal current_state, next_state : state_type;
signal count,count_next,count_next1,count1: unsigned( 7 downto 0);

begin

process(clk,reset)              -- The register process
begin
  if reset ='1' then
    current_state <= write_data;
    count <= (others => '0');
    count1 <= (others => '0');
    CS_enable <= '1' ;
 
elsif clk'event and clk = '1' then
    current_state <= next_state;
    count <= count_next;
    count1 <= count_next1;
    CS_enable <= '0' ;
end if;
end process;
process(current_state,count,count1,RAM_DATA,write_ack,data_input_ram,RYxSO_ack)
begin
next_state <= current_state;
 count_next <= count;
 count_next1 <= count1;
 data_out <= (others => '0');
data_RAM <= (others => '0');
 Addr <= (others => '0');
  WE_enable  <= '1' ;
--RYxSO_out <= '0';
case current_state is
  when write_data =>
    --RYxSO_out <=  RYxSO_ack;
      if  write_ack = '1' then
          if count < "1001111" then
          WE_enable <= '0' ;
            Addr <= std_logic_vector(count);
           data_out <= ("000000000000000" & std_logic_vector(RAM_DATA));
            count_next <=  count + 1;
           next_state <= write_data;
         elsif count = "1001111" then
            WE_enable <= '0' ;
            Addr <= std_logic_vector(count);
           data_out <= ("000000000000000" & std_logic_vector(RAM_DATA));
            count_next <=  (others => '0');
           next_state <= read_data;
          else
           WE_enable <= '0' ;
            Addr <= (others => '0');
          data_out <= (others => '0');
          count_next <= (others => '0');
          next_state <= write_data;
           end if;
    end if;
        when read_data => 
          -- RYxSO_out <=  RYxSO_ack;
             if (count1 < "1010010") then
          
              WE_enable <= '1' ;
            count_next1 <=  count1 + 1;
               Addr <= std_logic_vector(count1);
             data_RAM <= unsigned(data_input_ram(16 downto 0));
            next_state <= read_data;
               else
              WE_enable <= '0';
              Addr <= (others => '0');
              data_RAM <= (others => '0');
              count_next1 <=(others => '0');
               next_state <= write_data;
              end if;
           end case;
         end process;   
     end Behavioral;
