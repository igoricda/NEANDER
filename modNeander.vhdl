library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity modNeander is
    port(
        rst, clk : in std_logic
        );
end entity;

architecture comp of modNeander is

    
    --ULA
    component moduloULA is
	        port(
	            MEM_nrw: in std_logic;
	            rst, clk : in std_logic;
	            AC_nrw : in std_logic;
	            ula_op : in std_logic_vector(2 downto 0);
	            flags_nz : out std_logic_vector(1 downto 0);
	            barramento : inout std_logic_vector(7 downto 0)
	            );
    end component;
    
    --Memoria
    component moduloMEM is
        port(
            rst, clk : in std_logic;
            nbarrPC :  in std_logic;
            REM_nrw, MEM_nrw, RDM_nrw :  in std_logic;
            end_PC :  in std_logic_vector(7 downto 0);
            end_Barr :  in std_logic_vector(7 downto 0);
            Barramento : inout std_logic_vector(7 downto 0)
            );
    end component;
    
    --Controle
    component modulo_controle is
        port(
            interface_barramento: in std_logic_vector(7 downto 0);
            flagNZ : in std_logic_vector (1 downto 0);
            nrw, rst, clk: in std_logic;
            barramento_ctrl : out std_logic_vector (10 downto 0)              
            );
    end component;
    
    --pc
    component PC is
        port(
	        barr_inc : in  std_logic;
	        r_w, cl, clk : in       std_logic;
	        barr : in      std_logic_vector (7 downto 0);
	        saida_PC : out std_logic_vector (7 downto 0)
	        
        );
    end component;
    
    --BIT 10 = NBARR/INC
    --BIT 09 = NBARR/PC
    --BIT 08-07-06 = ULA_OP
    --BIT 05 = PC_NRW
    --BIT 04 = AC_NRW
    --BIT 03 = MEM_NRW
    --BIT 02 = REM_NRW
    --BIT 01 = RDM_NRW
    --BIT 00 = RI_NRW
    
    signal barr_data_inst, end_pc : std_logic_vector(7 downto 0);
    signal barramento_ctrl : std_logic_vector(10 downto 0);
    signal sNZflag : std_logic_vector(1 downto 0);

begin    

    uPC : PC port map (barramento_ctrl(10), barramento_ctrl(5), rst, clk, barr_data_inst, end_pc);
    uMEM : moduloMEM port map(rst, clk, barramento_ctrl(9), barramento_ctrl(2), barramento_ctrl(3), barramento_ctrl(1), end_pc, barr_data_inst, barr_data_inst);
    uULA : moduloULA port map(barramento_ctrl(3), rst, clk, barramento_ctrl(4), barramento_ctrl(8 downto 6), sNZflag, barr_data_inst);
    uCTRL : modulo_controle port map(barr_data_inst, sNZflag, barramento_ctrl(0), rst, clk, barramento_ctrl);
    
end architecture;
