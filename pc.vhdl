----------PC------------------
--Módulo Program Counter - PC

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity PC is
port(
	barr_inc : in  std_logic;
	r_w, cl, clk : in       std_logic;
	barr : in      std_logic_vector (7 downto 0);
	saida_PC : out std_logic_vector (7 downto 0)
	
);
end entity;

architecture main of PC is

	--incrementador do PC
	component fadder8 is
	port(
	    	a   : in std_logic_vector (7 downto 0);
            b   : in std_logic_vector (7 downto 0);
            cin : in std_logic;
            s   : out std_logic_vector (7 downto 0);
            cout : out std_logic
	);
	end component;	
	
	
	--registrador de instrução
	component regCarga8b is
	port(
		d : in std_logic_vector(7 downto 0);
		clk : in std_logic;
		pr, cl : in std_logic;
		nrw : in std_logic;
		s : out std_logic_vector(7 downto 0)
		);
	end component;
	
	signal sadd : std_logic_vector(7 downto 0);
	signal s_mux2pc : std_logic_vector(7 downto 0);
	signal s_PCatual : std_logic_vector(7 downto 0);
	signal sco : std_logic;
	
	begin
	--mux entre jump e incremento
	s_mux2pc <= sadd when barr_inc = '1' else barr;
	--incrementador
	u_test_adder8b : fadder8 port map("00000001", s_PCatual, '0', sadd, sco);
	--RIP
	u_test_reg : regCarga8b port map(s_mux2pc, clk, '1', cl, r_w, s_PCatual);
	
	saida_PC <= s_PCatual;
	

end architecture main;
