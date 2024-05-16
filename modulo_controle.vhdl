library IEEE;
use IEEE.std_logic_1164.all;

entity modulo_controle is

    port(
        interface_barramento: in std_logic_vector(7 downto 0);
        flagNZ : in std_logic_vector (1 downto 0);
        nrw, rst, clk: in std_logic;
        barramento_ctrl : out std_logic_vector (10 downto 0)              
        );
end entity;

architecture behavior of modulo_controle is
	
--decodificador de instruções	
	component decod_8_to_11 is
	    port(
		    instr_in_decode : in std_logic_vector(7 downto 0);
	        instr_out_decode :out std_logic_vector(10 downto 0)
	        );
	end component;
	
--Registrador de instruções	
	component regCarga8b is
	    port(
	        d : in std_logic_vector(7 downto 0);
	        clk : in std_logic;
	        pr, cl : in std_logic;
	        nrw : in std_logic;
	        s : out std_logic_vector(7 downto 0)
	        );
	end component;
	
	component UC is
        port(
            dec2uc : in std_logic_vector(10 downto 0);
            NZ     : in std_logic_vector (1 downto 0);
            rst, clk: in std_logic;
            barr_ctrl : out std_logic_vector(10 downto 0)
            );
    end component;
    
    signal ri2dec : std_logic_vector(7 downto 0);
    signal dec2uc : std_logic_vector(10 downto 0);
    
    
	begin
	
	uRI : regCarga8b port map(interface_barramento, clk, '1', rst, nrw, ri2dec);
	uDEC : decod_8_to_11 port map(ri2dec, dec2uc);
	uUC : UC port map(dec2uc, flagnz, rst, clk, barramento_ctrl);
	
end architecture;

---------UC------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity UC is
    port(
        dec2uc : in std_logic_vector(10 downto 0);
        NZ     : in std_logic_vector (1 downto 0);
        rst, clk: in std_logic;
        barr_ctrl : out std_logic_vector(10 downto 0)
        );
end entity;

architecture comp of UC is

        component contador3bit is
	        port(
		        clock, reset : in std_logic;
		        c: out std_logic_vector(2 downto 0)
		        );
        end component;
        
        component nop is
                port(
                    counter : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component snot is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component add is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component sand is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component sor is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component sta is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component lda is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component jmp is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component jz is
                port(
                    counter : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component jn is
                port(
                    counter : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
        component hlt is
                port(
                    c : in std_logic_vector (2 downto 0);
                    s: out std_logic_vector (10 downto 0)   
                    );
        end component;
        
       signal sNOP, sSTA, sLDA, sADD, sOR_UC, sAND_UC, sNOT_UC, sJMP_UC, sJMPN_UC, sJMPZ_UC, sHLT : std_logic_vector(10 downto 0);
       signal sCTD : std_logic_vector(2 downto 0);
       
    begin
    
        uCONT    : contador3bit port map(clk, rst, sCTD);
        uNOP     : nop port map(sCTD, sNOP);
        uSTA     : STA port map(sCTD, sSTA);
        uLDA     : LDA port map(sCTD, sLDA);
        uADD     : ADD port map(sCTD, sADD);
        uOR_UC   : sOR port map(sCTD, sOR_UC);
        uAND_UC  : sAND port map(sCTD, sAND_UC);
        uNOT_UC  : sNOT port map(sCTD, sNOT_UC);
        uJMP_UC  : JMP port map(sCTD, sJMP_UC);
        uJMPN_UC : JN port map(sCTD, sJMPN_UC);
        uJMPZ_UC : JZ port map(sCTD, sJMPZ_UC);
        uHLT     : HLT port map(sCTD, sHLT);
        
        barr_ctrl <= sNOP when dec2uc = "10000000000" else
        sSTA when dec2uc = "01000000000" else
        sLDA when dec2uc = "00100000000" else
        sADD when dec2uc = "00010000000" else
        sAND_UC when dec2uc = "00001000000" else
        sOR_UC when  dec2uc = "00000100000" else
        sNOT_UC when dec2uc = "00000010000" else
        sJMP_UC when dec2uc = "00000001000" else

        sJMP_UC when dec2uc = ("00000000100") and (NZ(1) = '1') else    
        sJMPN_UC  when dec2uc = ("00000000100") and (NZ(1) = '0') else 

        sJMP_UC when dec2uc = ("00000000010") and (NZ(0) = '1') else
        sJMPZ_UC when dec2uc = ("00000000010") and (NZ(0) = '0') else
        sHLT when dec2uc = "00000000001" else (others => 'Z');
        
end comp;
               
                    

----Contador-----------------
library ieee;
use ieee.std_logic_1164.all;

entity contador3bit is
	port(
		clock, reset : in std_logic;
		c: out std_logic_vector(2 downto 0)
		);
end entity;
		
architecture comp of contador3bit is		
	component ffjk is
		port(
			j, k: in std_logic;
			clk : in std_logic;
			pr, cl : in std_logic;
			q, nq : out std_logic
		);
		end component;
		
	component uccounter is
		port(
			qa: in std_logic_vector(2 downto 0);
			j, k : out std_logic_vector(2 downto 0)
			);
		end component;
		
		signal sjj, skk, sq: std_logic_vector(2 downto 0);
		signal vcc : std_logic := '1';

begin
    u_ff0 : ffjk port map(sjj(0), skk(0), clock, reset, vcc, sq(0));
    u_ff1 : ffjk port map(sjj(1), skk(1), clock, vcc, reset, sq(1));
    u_ff2 : ffjk port map(sjj(2), skk(2), clock, vcc, reset, sq(2));
    u_uc :  uccounter port map(sq(2 downto 0), sjj(2 downto 0), skk(2 downto 0));
    
    c <= sq;    
end architecture;


------decod8to11----------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity decod_8_to_11 is
port(
	instr_in_decode : in std_logic_vector(7 downto 0);
	instr_out_decode :out std_logic_vector(10 downto 0)
);
end entity;

	
architecture behavior of decod_8_to_11 is

	begin
	
	instr_out_decode <= "10000000000" when instr_in_decode="00000000" else 
              "01000000000" when instr_in_decode="00010000" else 
              "00100000000" when instr_in_decode="00100000" else 
              "00010000000" when instr_in_decode="00110000" else 
              "00001000000" when instr_in_decode="01000000" else 
              "00000100000" when instr_in_decode="01010000" else 
              "00000010000" when instr_in_decode="01100000" else 
              "00000001000" when instr_in_decode="10000000" else 
              "00000000100" when instr_in_decode="10010000" else 
              "00000000010" when instr_in_decode="10100000" else 
              "00000000001" when instr_in_decode="11110000" else
                (others => 'Z'); 
	
	
end architecture;
-----------UcCounter-------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uccounter is
    port(
        qa   : in  std_logic_vector(2 downto 0);
        j, k : out std_logic_vector(2 downto 0)
        );
end uccounter;

architecture controle of uccounter is

begin
    j(0) <= '1';
    k(0) <= '1';
    j(1) <= qa(0);
    k(1) <= qa(0);
    j(2) <= qa(0) and qa(1);
    k(2) <= qa(0) and qa(1);

end architecture controle;

----------nop------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity nop is
        port(
            counter : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of nop is
    begin
    s(10) <= '1';
    s(9) <= '1';
    s(8 downto 6) <= "000";
    s(5) <= not counter(2) and not counter(1) and counter(0);
    s(4) <= '0';
    s(3) <= '0';
    s(2) <= not counter(2) and not counter(1) and not counter(0);
    s(1) <= not counter(2) and not counter(1) and counter(0);
    s(0) <= not counter(2) and counter(1) and not counter(0);
    end architecture;
    
----------not-----------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity snot is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of snot is
    begin
    s(10) <= '1';
    s(9) <= '1';
    s(8 downto 6) <= "100";
    s(5) <= not c(2) and not c(1) and c(0);
    s(4) <= c(2) and c(1) and c(0);
    s(3) <= '0';
    s(2) <= not c(2) and not c(1) and not c(0);
    s(1) <= not c(2) and not c(2) and c(0);
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;
    
---------add-----------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity add is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of add is
    begin
    s(10) <= '1';
    s(9) <= not c(2) or c(1) or not c(0);
    s(8 downto 6) <= "001";
    s(5) <= not c(1) and (c(2) xor c(0));
    s(4) <= c(2) and c(1) and c(0);
    s(3) <= '0';
    s(2) <= (not c(1) and (c(2) xnor c(0))) or (not c(2) and c(1) and c(0));
    s(1) <= (c(2) and not c(0)) or (not c(2) and not c(1) and c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;
    
--------and-----------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity sand is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of sand is
    begin
    s(10) <= '1';
    s(9) <= not c(2) or c(1) or not c(0);
    s(8 downto 6) <= "011";
    s(5) <= not c(1) and (c(2) xor c(0));
    s(4) <= c(2) and c(1) and c(0);
    s(3) <= '0';
    s(2) <= (not c(1) and (c(2) xnor c(0))) or (not c(2) and c(1) and c(0));
    s(1) <= (c(2) and not c(0)) or (not c(2) and not c(1) and c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;

--------or---------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity sor is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of sor is
    begin
    s(10) <= '1';
    s(9) <= not c(2) or c(1) or not c(0);
    s(8 downto 6) <= "010";
    s(5) <= not c(1) and (c(2) xor c(0));
    s(4) <= c(2) and c(1) and c(0);
    s(3) <= '0';
    s(2) <= (not c(1) and (c(2) xnor c(0))) or (not c(2) and c(1) and c(0));
    s(1) <= (c(2) and not c(0)) or (not c(2) and not c(1) and c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;
    
----------sta--------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity sta is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of sta is
    begin
    s(10) <= '1';
    s(9) <= not c(2) or (c(2) and not c(0));
    s(8 downto 6) <= "000";
    s(5) <= not c(1) and (c(2) xor c(0));
    s(4) <= '0';
    s(3) <= c(2) and c(1) and not c(0);
    s(2) <= (not c(2) and not c(1) and not c(0)) or (c(0) and (c(2) xor c(1)));
    s(1) <= not c(1) and (c(2) xor c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;
    
-----------------lda-------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity lda is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of lda is
    begin
    s(10) <= '1';
    s(9) <= not c(2) or c(1) or not c(0);
    s(8 downto 6) <= "000";
    s(5) <= not c(1) and (c(2) xor c(0));
    s(4) <= c(2) and c(1) and c(0);
    s(3) <= '0';
    s(2) <= (not c(1) and (c(2) xnor c(0))) or (not c(2) and c(1) and c(0));
    s(1) <= (c(2) and not c(0)) or (not c(2) and not c(1) and c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;

------jmp----------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity jmp is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of jmp is
    begin
    s(10) <= not c(2) or (not c(1) and not c(0));
    s(9) <= '1';
    s(8 downto 6) <= "000";
    s(5) <= not c(1) and c(0);
    s(4) <= '0';
    s(3) <= '0';
    s(2) <= not c(2) and (c(1) xnor c(0));
    s(1) <= not c(1) and (c(2) xor c(0));
    s(0) <= not c(2) and c(1) and not c(0);
    end architecture;
    
-----------jz---------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity jz is
        port(
            counter : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of jz is
    begin
    s(10) <= '1';
    s(9) <= '1';
    s(8 downto 6) <= "000";
    s(5) <= not counter(2) and counter(0);
    s(4) <= '0';
    s(3) <= '0';
    s(2) <= not counter(2) and not counter(1) and not counter(0);
    s(1) <= not counter(2) and not counter(1) and counter(0);
    s(0) <= not counter(2) and counter(1) and not counter(0);
    end architecture;
    
--------------jn---------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity jn is
        port(
            counter : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of jn is
    begin
    s(10) <= '1';
    s(9) <= '1';
    s(8 downto 6) <= "000";
    s(5) <= not counter(2) and counter(0);
    s(4) <= '0';
    s(3) <= '0';
    s(2) <= not counter(2) and not counter(1) and not counter(0);
    s(1) <= not counter(2) and not counter(1) and counter(0);
    s(0) <= not counter(2) and counter(1) and not counter(0);
    end architecture;
    
----------hlt------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity hlt is
        port(
            c : in std_logic_vector (2 downto 0);
            s: out std_logic_vector (10 downto 0)   
            );
end entity;

architecture comp of hlt is
    begin
    s <= "00000000000";
    end architecture;


