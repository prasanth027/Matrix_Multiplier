----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2020 08:49:30
-- Design Name: 
-- Module Name: Coeff_Data - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Coeff_Data is
  port (clk             : in  std_logic;
        reset           : in  std_logic;
        Rom_enable      : in  std_logic;  --- Starts fetching data ack
        data_coeff      : in  unsigned (6 downto 0);  ---- input data from the text file
        start_operation : in  std_logic;  ----- input ack to send the data from registers to
        data_ack        : in  std_logic;  ----- receives ack after completing 4 multiplications 
        coeff_out       : out unsigned (27 downto 0);  ----- sends first four digits of a row to multuplier unit
        Rom_enablecomp  : out std_logic  --- Completed Extracting Data ACK to main controller
        );
end Coeff_Data;

architecture Behavioral of Coeff_Data is
  type   state_type is (idle, fetch_data,null1,n1,send_data,s0,s1,s2,s3,s4,s5,s6,s7);
  signal current_state, next_state : state_type;
  signal count, count_next         : unsigned(6 downto 0);
  signal count1, count1_next         : unsigned(3 downto 0);
  signal register_matrix           : unsigned(223 downto 0);
  signal register_matrix_reg         : unsigned(223 downto 0);
 
  begin
  process(clk, reset)            -- The register process
  begin
    if reset = '1' then
      current_state <= idle;
      count         <= (others => '0');
      count1         <= (others => '0');
       register_matrix_reg <= (others => '0');
 elsif clk'event and clk = '1' then
      current_state <= next_state;
       count  <= count_next;
       count1  <= count1_next;
 register_matrix_reg <= register_matrix ;  
  end if;
  end process;
  process(current_state,Rom_enable,data_coeff,count1,data_ack, start_operation, count,register_matrix,register_matrix_reg)
  begin
    next_state     <= current_state;
    Rom_enablecomp <= '0';
    register_matrix <= register_matrix_reg;
    count_next  <= count;
    count1_next  <= count1;
   coeff_out      <= (others => '0');
    case current_state is
      when idle =>
     if Rom_enable = '1' then
          next_state <= fetch_data;
              coeff_out      <= (others => '0');
        else
          next_state <= idle;
              coeff_out      <= (others => '0');
        end if;
      when fetch_data =>
        if count < 32 then
          register_matrix <= register_matrix_reg (216 downto 0)& data_coeff;  ----- register for storing 32 elements
          Rom_enablecomp  <= '0';
          count_next      <= count + 1;
          next_state      <= fetch_data;
        else
          register_matrix <= register_matrix_reg;
              coeff_out      <= (others => '0');
          Rom_enablecomp  <= '1';
          count_next      <= (others => '0');
          next_state      <= send_data;
       
        end if;
      when send_data =>
   if start_operation = '1' then
          next_state <= null1;
        else
          next_state <= send_data;
        end if;
      when null1 =>
   
        if count1 < "100"  then
          count1_next <= count1 + 1;
          next_state <= n1;
        else
          count1_next <= (others => '0');
          next_state <= idle;
        end if;
      when n1 =>
            next_state <= s0;  
      when s0=> 
    
       if data_ack = '1'  then  
       coeff_out  <= register_matrix(223 downto 196);
       next_state <= s1;
        else
          coeff_out  <= (others => '0');
          next_state <= s0;
           end if;
         
     when s1=> 
       
            if data_ack = '1'  then
             coeff_out <=  register_matrix(195 downto 168);
             next_state <= s2;
             else
               coeff_out  <= (others => '0');
               next_state <= s1;
             end if;
     when s2=> 
        
               if data_ack = '1' then
               coeff_out <=   register_matrix(167 downto 140);
               next_state <= s3;
             else
               coeff_out <=  (others => '0');
             next_state <= s2;
             end if;
      when s3 => 
             if data_ack = '1'  then
               coeff_out <=  register_matrix(139 downto 112);
                next_state <= s4;
              else
                coeff_out <=  (others => '0');
               next_state <= s3;
               end if;
        when s4 => 
           
                if data_ack = '1'  then
               coeff_out <=  register_matrix(111 downto 84);
                next_state <= s5;
              else
                coeff_out <=  (others => '0');
                next_state <= s4;
              end if;
        when s5 =>  

               if data_ack = '1'  then
               coeff_out <=  register_matrix(83 downto 56);
                next_state <= s6;
              else
                coeff_out <=  (others => '0');
                next_state <= s5;
              end if;
           when s6 =>
           
                if data_ack = '1'  then
               coeff_out <=  register_matrix(55 downto 28);
                next_state <= s7;
              else
                coeff_out <=  (others => '0');
                next_state <= s6;
              end if;
           when s7 =>
     
              if data_ack = '1'  then
               coeff_out <=  register_matrix(27 downto 0);
                next_state <= null1;
              else
                 coeff_out <=  (others => '0');
                  next_state <= s7;
               end if;   
              end case;
            end process;
end Behavioral;
