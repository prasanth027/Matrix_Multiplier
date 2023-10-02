library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity IC_PROJECT_top is
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    start_fetching : in  std_logic;     --- Start button
    data_in        : in  unsigned (7 downto 0);
    data_coeff     : in  unsigned (6 downto 0);  ---- input data from the text file
    data_RAM       : out unsigned (16 downto 0);
    matrix_out     : out std_logic
    );
end IC_PROJECT_top;

architecture IC_PROJECT_top_arch of IC_PROJECT_top is

  component Main_Controller is
    port (clk                   : in  std_logic;
          reset                 : in  std_logic;
          start_fetching        : in  std_logic;  --- Start button  
          Ram_enablecomp        : in  std_logic;  --- Completed Extracting Data ACK
          Rom_enablecomp        : in  std_logic;  --- Completed Extracting Data ACK
          Matrix_mul            : in  std_logic;  ---  receives matrix multiplication completed ack
          start_operation_input : out std_logic;  --- starts multiplication process
          start_operation_coeff : out std_logic;
          start_operation_mul   : out std_logic;
          matrix_out            : out std_logic;
          Ram_enable            : out std_logic;  --- Starts fetching data to RAM
          Rom_enable            : out std_logic  --- Starts fetching data to ROM  
          );
  end component;

  component Coeff_Data is
    port (clk             : in  std_logic;
          reset           : in  std_logic;
          Rom_enable      : in  std_logic;  --- Starts fetching data ack
          data_coeff      : in  unsigned (6 downto 0);  ---- input data from the text file
          start_operation : in  std_logic;  ----- input ack to send the data from registers to
          data_ack        : in  std_logic;  ----- receives ack after completing 4 multiplications 
          Rom_enablecomp  : out std_logic;  --- Completed Extracting Data ACK to main controller
          coeff_out       : out unsigned (27 downto 0)  ----- sends first four digits of a row to multuplier unit
          );
  end component;

  component Input_data is
    port (clk             : in  std_logic;
          reset           : in  std_logic;
          Ram_enable      : in  std_logic;  --- Starts fetching data ack
          data_in         : in  unsigned (7 downto 0);  ---- input data from the text file
          start_operation : in  std_logic;  ----- input ack to send the data from registers to 
          data_ack        : in  std_logic;  ----- receives ack after completing 4 multiplications
          data_out1       : out unsigned (31 downto 0);  ----- sends first four digits of a row to multuplier unit
          Ram_enablecomp  : out std_logic  --- Completed Extracting Data ACK to main controller
          );  
  end component;

  component multiply is
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
  end component;

  component RAM is
    port (clk            : in  std_logic;
          reset          : in  std_logic;
          RAM_DATA       : in  unsigned (16 downto 0);
          write_ack      : in  std_logic;
          data_input_ram : in  std_logic_vector (31 downto 0);
          RYxSO_ack      : in  std_logic;
          CS_enable      : out std_logic;  -- Active Low
          WE_enable      : out std_logic;  --Active Low
          data_RAM       : out unsigned (16 downto 0);
          Addr           : out std_logic_vector (7 downto 0);
          data_out       : out std_logic_vector (31 downto 0)
          );
  end component;
  component SRAM_SP_WRAPPER is
    port (
      ClkxCI  : in  std_logic;
      CSxSI   : in  std_logic;             -- Active Low
      WExSI   : in  std_logic;             --Active Low
      AddrxDI : in  std_logic_vector (7 downto 0);
      DataxDI : in  std_logic_vector (31 downto 0);
      DataxDO : out std_logic_vector (31 downto 0);
      RYxSO   : out std_logic
      );
  end component;

  signal ram_enable, rom_enable, ramenable_comp, romenable_comp, matrix_mul, start_operation_sig1, start_operation_sig2, start_operation_sig3, write_ack_sig, data_ack_sig, RYxSOack_TOP : std_logic;
  signal data_out1_sig                                                                                                                                                                   : unsigned (31 downto 0);
  signal data_out_sig                                                                                                                                                                    : std_logic_vector(31 downto 0);
  signal coeff_out_sig                                                                                                                                                                   : unsigned (27 downto 0);
  signal ram_sig                                                                                                                                                                         : unsigned (16 downto 0);
  signal CS_enable1, WE_enable1                                                                                                                                                          : std_logic;
  signal Addr1                                                                                                                                                                           : std_logic_vector(7 downto 0);
  signal data_out_mem                                                                                                                                                                    : std_logic_vector(31 downto 0);


begin
  
  Main_Controller_INST : Main_Controller
    port map (clk                    => clk,
               reset                 => reset,
               start_fetching        => start_fetching,
               Ram_enable            => ram_enable,
               Rom_enable            => rom_enable,
               Ram_enablecomp        => ramenable_comp,
               Rom_enablecomp        => romenable_comp,
               Matrix_mul            => matrix_mul,
               start_operation_input => start_operation_sig1,
               start_operation_coeff => start_operation_sig2,
               start_operation_mul   => start_operation_sig3,
               matrix_out            => matrix_out
               );
  Coeff_Data_INST : Coeff_Data
    port map (clk             => clk,
              reset           => reset,
              Rom_enable      => rom_enable,
              Rom_enablecomp  => romenable_comp,
              data_coeff      => data_coeff,
              start_operation => start_operation_sig2,
              coeff_out       => coeff_out_sig,
              data_ack        => data_ack_sig
              );

  Input_data_INST : Input_data
    port map (clk             => clk,
              reset           => reset,
              Ram_enable      => ram_enable,
              Ram_enablecomp  => ramenable_comp,
              data_in         => data_in,
              start_operation => start_operation_sig1,
              data_out1       => data_out1_sig,
              data_ack        => data_ack_sig
              );
  multiply_INST : multiply
    port map (clk         => clk,
              reset       => reset,
              start       => start_operation_sig3,
              data_input1 => data_out1_sig,
              data_coeff  => coeff_out_sig,
              data_ack    => data_ack_sig,
              Matrix_mul  => matrix_mul,
              RAM_DATA    => ram_sig,
              write_ack   => write_ack_sig
              );
  
 SRAM_SP_WRAPPER_INST : SRAM_SP_WRAPPER
    port map (ClkxCI  => clk,
              CSxSI   => CS_enable1,    -- Active Low
              WExSI   => WE_enable1,    --Active Low
              AddrxDI => Addr1,
              RYxSO   => RYxSOack_TOP,
              DataxDI => data_out_sig,
              DataxDO => data_out_mem
              );  

  RAM_INST : RAM
    port map (clk            => clk,
              reset          => reset,
              RAM_DATA       => ram_sig,
              write_ack      => write_ack_sig,
              data_out       => data_out_sig,
              CS_enable      => CS_enable1,
              WE_enable      => WE_enable1,
              RYxSO_ack      => RYxSOack_TOP,
              data_input_ram => data_out_mem,
              data_RAM       => data_RAM,
              Addr           => Addr1
              );

end IC_PROJECT_top_arch;

