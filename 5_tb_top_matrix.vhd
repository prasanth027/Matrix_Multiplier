library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.tb_pkg.all;


entity tb5_top_matrix is
end tb5_top_matrix;

architecture behavior of tb5_top_matrix is

component top_matrix is
Port (clk_top: in std_logic;
      rst_top: in std_logic;
      start_top :in std_logic;
      input_matrix1: in unsigned(7 downto 0);
      coeff_matrix1 : in unsigned(6 downto 0);
      display_top: out std_logic_vector(16 downto 0);
      matrix_mul_finish: out std_logic
      );
end component;

type state_type is (idle, inputfetch,next_load,new_matrix);
signal current_state, next_state : state_type; 
signal clk_top, rst_top, matrix_mul_finish_tb: std_logic := '0';
--signal    dataread : integer; --std_logic_vector(7 downto 0); --real;
signal input_matrix1 : unsigned(7 downto 0) := (others => '0');
signal coeff_matrix1 : unsigned(6 downto 0) := (others => '0');
signal  start_top: std_logic:='0';
signal display_top: std_logic_vector(16 downto 0);
signal ele_count_d, ele_count_q, array_pointer_q, array_pointer_d, coeff_addr_d, coeff_addr_q,matrix_counter_d,matrix_counter_q : integer := 0;

 constant period   : time := 100 ns;

   -- GetCodeFromFile a complicated function to decode ASCII to corresponding kb code !!
   
    signal input_data : word_arr := GetCodeFromFile("/h/d8/v/sa4464ba-s/Program/ICP1/synthesis/input.txt");
    signal coeff_data : word_arr_coeff := GetCoeffFromFile("/h/d8/v/sa4464ba-s/Program/ICP1/synthesis/coeff.txt");

 begin
 rst_top <= '1' after 1 ns,
         '0' after 150 ns;
	clk_top <= not (clk_top) after 250 ns;	  
	--start_top <= '1' after 3*period;	 
top: top_matrix
   port map ( clk_top   => clk_top,     
          rst_top  => rst_top,   
          start_top  => start_top, 
          input_matrix1 =>  input_matrix1,  
          coeff_matrix1  => coeff_matrix1, 
          display_top =>  display_top,  
          matrix_mul_finish  => matrix_mul_finish_tb     
        );
	   
tb_sequential: process(rst_top, clk_top)
begin
    if rst_top = '1' then
	  current_state <= idle;
	  ele_count_q <= 0;
      coeff_addr_q <= 0;
      array_pointer_q <= 0;
      matrix_counter_q <= 0;
     elsif clk_top 'event and clk_top = '1' then
        current_state <= next_state;
        array_pointer_q<= array_pointer_d;
        coeff_addr_q <= coeff_addr_d;
        ele_count_q   <= ele_count_d;
        matrix_counter_q <= matrix_counter_d;
     end if;	
end process tb_sequential;

tb_comb: process(current_state, ele_count_q, input_data, array_pointer_q, start_top, coeff_addr_q, coeff_data,matrix_counter_q,matrix_mul_finish_tb) 
begin

next_state <= current_state;
input_matrix1 <= (others => '0');
coeff_matrix1 <= (others => '0');
ele_count_d <= ele_count_q;
coeff_addr_d <= coeff_addr_q;
array_pointer_d <= array_pointer_q;
matrix_counter_d <= matrix_counter_q;

case current_state is    
		
when idle =>
         
			if (matrix_counter_q <5) then
			 start_top <= '1';
			 next_state <= new_matrix;
			    else
			  start_top <= '0';
			 next_state <= idle;
		end if;
		
when new_matrix=>
			 next_state <= inputfetch;
			 
when inputfetch =>
    if (ele_count_q < 32) then
    input_matrix1 <= unsigned(input_data(array_pointer_q));
    coeff_matrix1 <= unsigned(coeff_data(coeff_addr_q));
    ele_count_d <= ele_count_q + 1;
    coeff_addr_d <= coeff_addr_q + 1;
    array_pointer_d <= array_pointer_q + 1;
    matrix_counter_d<= matrix_counter_q;
    next_state <= inputfetch;
  else
   ele_count_d <= ele_count_q;
   array_pointer_d <= array_pointer_q;
   coeff_addr_d <= coeff_addr_q;
   matrix_counter_d <= matrix_counter_q;
   next_state <= next_load;
end if;
when next_load =>
  if(matrix_mul_finish_tb = '1')then
   ele_count_d <= 0;
   array_pointer_d <= array_pointer_q;
   coeff_addr_d <= 0;
   next_state <= idle;
   matrix_counter_d <= matrix_counter_q + 1;
 else
   ele_count_d <= ele_count_q;
   array_pointer_d <= array_pointer_q;
   coeff_addr_d <= coeff_addr_q;
   matrix_counter_d <= matrix_counter_q;
   next_state <= next_load;
 end if;
  
when others => null;
end case;
end process tb_comb;


-- if (coeff_count_q < 1) then
--     if (input_count_q < 32) then
      
--    input_matrix1 <= unsigned(input_data(array_pointer_q));
--    coeff_matrix1 <= unsigned(coeff_data(array_pointer_q));
--    input_count_d <= input_count_q + 1;
--    array_pointer_d <= array_pointer_q + 1;
--    next_state <= inputfetch;
-- else
--   input_count_d <= 0;
--   next_state <= idle;
--   coeff_count_d <= coeff_count_q + 1;
-- end if;

--else 
--    if (input_count_q < 32) then
--   input_matrix1 <= unsigned(input_data(array_pointer_q));
--    input_count_d <= input_count_q + 1;
--    array_pointer_d <= array_pointer_q + 1;
--    next_state <= inputfetch;
-- elsif(matrix_mul_finish_tb = '1')then
--   input_count_d <= 0;
--   array_pointer_d <= 0;
--   coeff_count_d <= 0;
--   next_state <= idle;
--   matrix_counter_d <= matrix_counter_q + 1;
-- else
--    input_count_d <= input_count_q;
--   array_pointer_d <= array_pointer_q;
--   coeff_count_d <= coeff_count_q;
--   next_state <= inputfetch;
--   matrix_counter_d <= matrix_counter_q;
-- end if;
-- end if;


end behavior;
