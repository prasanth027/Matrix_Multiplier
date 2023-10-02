----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.02.2020 12:54:00
-- Design Name: 
-- Module Name: Input_data - Behavioral
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

entity Input_data is
Port (clk     : in  std_logic;
      reset   : in  std_logic;
      Ram_enable: in  std_logic;      --- Starts fetching data ack
      data_in :in unsigned (7 downto 0);  ---- input data from the text file
      start_operation : in  std_logic;     ----- input ack to send the data from registers to 
      data_out1 :out unsigned (31 downto 0); ----- sends first four digits of a row to multuplier unit
     data_ack  : in  std_logic;              ----- receives ack after completing 4 multiplications
     Ram_enablecomp : out  std_logic   --- Completed Extracting Data ACK to main controller
    );  
end Input_data;

architecture Behavioral of Input_data is
type state_type is (idle,r0,r1,r2,r3,send_data,s0,s1,s2,s3,s4,s5,s6,s7,n0,n1,n2,n3);
signal current_state, next_state : state_type;
signal count,count_next: unsigned( 6 downto 0);
signal count1,count2,count3,count4,count1_next,count2_next,count3_next,count4_next: unsigned( 2 downto 0);
signal input_matrix:unsigned( 7 downto 0);
signal register_matrix1,register_matrix2,register_matrix3,register_matrix4:unsigned( 63 downto 0);
signal register_matrix_reg1,register_matrix_reg2,register_matrix_reg3,register_matrix_reg4:unsigned( 63 downto 0);
--signal data_in_reg,data_in_reg1:unsigned( 7 downto 0):= (others => '0');
begin
process(clk,reset,count)              -- The register process
begin
  if reset ='1' then
    current_state <= idle;
    count  <= (others => '0');
    register_matrix_reg1 <= (others => '0');
    register_matrix_reg2 <= (others => '0');
    register_matrix_reg3 <= (others => '0');
    register_matrix_reg4 <= (others => '0');
     count1  <= (others => '0');
      count2  <= (others => '0');
       count3  <= (others => '0');
        count4  <= (others => '0');
 elsif clk'event and clk = '1' then
    current_state <= next_state;
    count  <= count_next;
 register_matrix_reg1 <= register_matrix1;
register_matrix_reg2 <= register_matrix2;
register_matrix_reg3 <= register_matrix3;
register_matrix_reg4 <= register_matrix4;
count1  <= count1_next;
      count2  <= count2_next;
       count3  <= count3_next;
        count4  <= count4_next;
 end if;
end process;
comb: process(current_state,Ram_enable,register_matrix1,register_matrix2,register_matrix3,register_matrix4,data_ack,start_operation,count,data_in,count1,count2_next,count2,count3,count4,register_matrix_reg1,register_matrix_reg2,register_matrix_reg3,register_matrix_reg4)
begin
 next_state <= current_state;
  Ram_enablecomp <= '0';
  register_matrix1 <= register_matrix_reg1;
   register_matrix2 <= register_matrix_reg2;
   register_matrix3 <= register_matrix_reg3;
   register_matrix4 <= register_matrix_reg4;
   count_next  <= count;
   count1_next  <= count1;
   count2_next  <= count2;
   count3_next  <= count3;
   count4_next  <= count4;
 data_out1 <= (others => '0');
   case current_state is
 when idle =>
   if Ram_enable = '1' then
     next_state <= r0 ;
     else
     next_state <= idle;
    end if; 
  when r0 =>
       if count < "1000" then     ---- counts for 32 digits
         register_matrix1 <=  data_in & register_matrix_reg1(63 downto 8);    ----- register for storing 32 elements
       count_next <= count + 1;
          Ram_enablecomp <= '0';
         next_state <= r1;
         else
         Ram_enablecomp <= '1';
         count_next <= (others => '0');
         register_matrix1 <=  register_matrix_reg1; 
         next_state <= send_data;
       end if;
  when r1 =>      
        register_matrix2 <=  data_in & register_matrix_reg2(63 downto 8);
         next_state <= r2;
    when r2 =>      
        register_matrix3 <=  data_in & register_matrix_reg3(63 downto 8);
         next_state <= r3;
    when r3 =>      
        register_matrix4 <=  data_in & register_matrix_reg4(63 downto 8);
         next_state <= r0;
    when send_data =>
       if start_operation = '1' then
          next_state <= n0;
        else
          next_state <= send_data ;
        end if;
      when n0 =>
           if  count1 < "100" then
            count1_next <= count1 + 1;
            next_state <= s0;
          else
            count1_next <= (others => '0');
            next_state <= n1;
          end if;
       
         when s0 =>
            if data_ack = '1' then
             data_out1 <= register_matrix1(31 downto 0);
           next_state <= s1;
           else
             data_out1 <= (others => '0');
              next_state <= s0;
           end if;
        
       when s1 =>  
         if data_ack = '1'  then
           data_out1 <= register_matrix1(63 downto 32);
             next_state <= n0;
          else
             data_out1 <= (others => '0');
              next_state <= s1;
              end if;
        when n1 =>
           if  count2 < "100" then
            count2_next <= count2 + 1;
            next_state <= s2;
          else
            count2_next <= (others => '0');
            next_state <= n2;
          end if;                
         when s2 =>  
           if   data_ack = '1' then
           data_out1 <= register_matrix2(31 downto 0);
            next_state <= s3;
          else
             data_out1 <= (others => '0');
            next_state <= s2;
              end if;
           when s3 =>  
               if data_ack = '1'  then
           data_out1 <= register_matrix2(63 downto 32);
             next_state <= n1;
          else
             data_out1 <= (others => '0'); 
              next_state <= s3;
              end if;
              
          when n2 =>
           if  count3 < "100" then
            count3_next <= count3 + 1;
            next_state <= s4;
          else
            count3_next <= (others => '0');
            next_state <= n3;
          end if;                     
              
          when s4 =>  
           if  data_ack = '1'   then
           data_out1 <= register_matrix3(31 downto 0);
            next_state <= s5;
          else
             data_out1 <= (others => '0');
            next_state <= s4;
              end if;
           when s5 =>  
               if data_ack = '1'  then
           data_out1 <= register_matrix3(63 downto 32);
             next_state <= n2;
          else
             data_out1 <= (others => '0'); 
              next_state <= s5;
            end if;
         when n3 =>
           if  count4 < "100" then
            count4_next <= count4 + 1;
            next_state <= s6;
          else
            count4_next <= (others => '0');
            next_state <= idle;
          end if; 
         
          when s6 =>  
            if  data_ack = '1'   then
           data_out1 <= register_matrix4(31 downto 0);
               next_state <= s7;
          else
             data_out1 <= (others => '0');
           next_state <= s6;
              end if;
           when s7 =>  
               if data_ack = '1'  then
           data_out1 <= register_matrix4(63 downto 32);
             next_state <= n3;
          else
             data_out1 <= (others => '0'); 
              next_state <= s7;
             end if;
              end case;
            end process;   
 end Behavioral;
