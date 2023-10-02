----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2020 00:53:38
-- Design Name: 
-- Module Name: multiply - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiply is
  port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    start       : in  std_logic;
    data_input1 : in  unsigned (31 downto 0);
    data_coeff  : in  unsigned (27 downto 0);
    data_ack    : out std_logic;
    Matrix_mul  : out std_logic;
    write_ack   : out std_logic;
    RAM_DATA    : out unsigned (16 downto 0)
    );
end multiply;

architecture Behavioral of multiply is
  type   state_type is (idle, multiply, send_data, delay, add);
  signal current_state, next_state              : state_type;
--signal M1,M2,M3,M4:unsigned( 15 downto 0):= (others => '0');
  signal A1,A1_REG                                     : unsigned(16 downto 0);
  signal matrix_element, matrix_element_reg     : unsigned(16 downto 0);
  signal count, count_next, count1, count1_next : unsigned(1 downto 0);
  signal count2, count2_next                    : unsigned(5 downto 0);
  signal register_data                          : unsigned(33 downto 0);
  signal register_data_reg                      : unsigned(33 downto 0);
begin
  process(clk, reset)
  begin
    if reset = '1' then
      current_state      <= idle;
      count              <= (others => '0');
      count2             <= (others => '0');
      count1             <= (others => '0');
      A1_REG              <= (others => '0');
      matrix_element_reg <= (others => '0');
    elsif clk'event and clk = '1' then
      current_state      <= next_state;
      count              <= count_next;
      count2             <= count2_next;
      count1             <= count1_next;
      matrix_element_reg <= matrix_element;
      A1_REG              <= A1;
      
    end if;
  end process;
  process(current_state, count, count2, count1, register_data, matrix_element, matrix_element_reg, start, register_data_reg, data_input1, data_coeff, A1_REG)
  begin
    next_state  <= current_state;
    RAM_DATA    <= (others => '0');
    Matrix_mul  <= '0';
    data_ack    <= '0';
    write_ack   <= '0';
    count_next  <= count;
    count2_next <= count2;
    count1_next <= count1;

    matrix_element <= matrix_element_reg;
    case current_state is
      when idle =>
        if start = '1' then
          next_state <= delay;
        else
          next_state <= idle;
        end if;
        A1 <= A1_REG;
      when delay =>
        if count1 < "01" then
          count1_next <= count1 + 1;
          next_state  <= delay;
        else
          count1_next <= (others => '0');
          next_state  <= multiply;
        end if;
        A1 <= A1_REG;
      when multiply =>
        data_ack   <= '1';
        A1         <= "0"&(("0"&(data_input1(7 downto 0)*data_coeff(27 downto 21)))+("0"&(data_input1(15 downto 8)*data_coeff(20 downto 14)))+("0"&(data_input1(23 downto 16)*data_coeff(13 downto 7)))+("0"&(data_input1(31 downto 24)*data_coeff(6 downto 0))));
        next_state <= add;
      when add =>
        if count < "10" then
          matrix_element <= matrix_element_reg + A1_REG;
          count_next     <= count + 1;
          next_state     <= multiply;
          if count = "01" then
            count_next <= (others => '0');
            next_state <= send_data;
          else
            count1_next <= (others => '0');
            next_state  <= multiply;
          end if;
        else
          matrix_element <= matrix_element_reg;
          count_next     <= (others => '0');
          next_state     <= send_data;
        end if;
        A1 <= (others => '0');
      when send_data =>
        A1 <= A1_REG;
        if count2 < "10000" then
          count2_next    <= count2 + 1;
          write_ack      <= '1';
          RAM_DATA       <= matrix_element_reg;
          matrix_element <= (others => '0');
          Matrix_mul     <= '0';
          next_state     <= multiply;
        else
          count2_next <= (others => '0');
          write_ack   <= '0';
          RAM_DATA    <= (others => '0');
          Matrix_mul  <= '1';
          next_state  <= idle;
        end if;
    end case;
  end process;
end Behavioral;

