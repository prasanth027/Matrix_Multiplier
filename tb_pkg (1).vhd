library ieee; 
use ieee.numeric_std.all; 
use ieee.std_logic_1164.all; 
use std.textio.all;  
use ieee.std_logic_textio.all;


package tb_pkg is 
    -- create a memory almost 1Kb to store all keyboard stimulus from file
  --  subtype kb_word_t is unsigned(10 downto 0);
    type word_arr is array (159 downto 0) of unsigned(7 downto 0);
	type word_arr_coeff is array (31 downto 0) of unsigned(6 downto 0);
    constant max_mem_size : natural := 159;

    impure function GetCodeFromFile (inputfilename: in string) return word_arr;
    impure function GetCoeffFromFile (inputfilename: in string) return word_arr_coeff;	
 --   function function_parity (a: unsigned) return std_logic;
  --  function reverse_any_vector (a: in unsigned) return unsigned; 

end tb_pkg; 


package body tb_pkg is

    impure function GetCodeFromFile (inputfilename: in string) return word_arr is
	file inputfile_handle         : text;
	variable inputfileline : line;
	variable INPUT         : word_arr;
	variable ww            : std_logic_vector(7 downto 0);
	variable i            : integer := 0;
	variable count : integer:= 159;
    begin
      file_open(inputfile_handle, inputfilename ,  read_mode);
	while ((not endfile(inputfile_handle)) and (i <= count)) loop
		readline (inputfile_handle, inputfileline);
	  read(inputfileline, ww);	
		--hread(inputfileline, ww);
		INPUT(i) := unsigned(ww);
		i := i + 1;
	end loop;
	
	return INPUT;

    end function;

   impure function GetCoeffFromFile (inputfilename: in string) return word_arr_coeff is
	file inputfile_handle         : text;
	variable inputfileline : line;
	variable COEFF         : word_arr_coeff;
	variable ww            : std_logic_vector(6 downto 0);
	variable i            : integer := 0;
	variable count : integer:= 31;
    begin
      file_open(inputfile_handle, inputfilename ,  read_mode);
	while ((not endfile(inputfile_handle)) and (i <= count)) loop
		readline (inputfile_handle, inputfileline);
	  read(inputfileline, ww);	
		--hread(inputfileline, ww);
		COEFF(i) := unsigned(ww);
		i := i + 1;
	end loop;
	
	return COEFF;

    end function;

end package body;
 
