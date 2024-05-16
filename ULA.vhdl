library IEEE;
use IEEE.std_logic_1164.all;

entity moduloULA is
	port(
	     rst, clk    : in    std_logic;
         AC_nrw      : in    std_logic;
         ula_op      : in    std_logic_vector(2 downto 0);
         MEM_nrw     : in    std_logic;
         flags_nz    : out   std_logic_vector(1 downto 0);
		 barramento  : inout std_logic_vector(7 downto 0)
	    );
end entity moduloULA;

architecture alu of moduloULA is

	component regCarga8b is
		port(
		     d : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic_vector(7 downto 0)
            );
	end component;
	
	component regCarga2b is
		port(
		     d : in std_logic_vector(1 downto 0);
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic_vector(1 downto 0)
            );
	end component;
	
	component moduloULAinterno is
		port(
		     x, y : in std_logic_vector(7 downto 0);
		     ula_op : in std_logic_vector(2 downto 0);
		     flags_nz : out std_logic_vector(1 downto 0);
		     s : out std_logic_vector (7 downto 0)
		    );
	end component;
	
	signal s_ac2ula, s_ula2ac : std_logic_vector(7 downto 0);
	signal s_ula2flags : std_logic_vector(1 downto 0);
	
begin
	--registrador AC
	u_regAC : regCarga8b  port map(s_ula2ac, clk, '1', rst, AC_nrw, s_ac2ula) ;
	
	--registrador FLAGS
	u_regflags : regCarga2b port map(s_ula2flags, clk, '1', rst, AC_nrw, flags_nz);
	
	--Modulo ULA Interno
	u_ulainterno : moduloULAinterno port map(s_ac2ula, barramento, ula_op, s_ula2flags, s_ula2ac);
	barramento <= s_ac2ula when MEM_nrw = '1' else (others => 'Z');
end architecture alu;
	
	
------------ neander modulo interno ==================

library IEEE;
use IEEE.std_logic_1164.all;	

entity moduloULAinterno is
	port(
	     x, y : in std_logic_vector(7 downto 0);
	     ula_op : in std_logic_vector(2 downto 0);
	     flags_nz : out std_logic_vector(1 downto 0);
	     s : out std_logic_vector(7 downto 0)
	     );
end entity;

architecture aluinterna of moduloUlainterno is
	
	signal sand, sor, snot, slda, ss : std_logic_vector(7 downto 0);
	signal sadd, saadc : std_logic_vector(7 downto 0);
	signal saddoverflow : std_logic;
	
	--ADDER	
	component fadder8 is
	    port(
		a   : in std_logic_vector(7 downto 0);
		b   : in std_logic_vector(7 downto 0);
		cin : in std_logic;
		s   : out std_logic_vector (7 downto 0);
		cout : out std_logic
	    );
	end component;
	
 begin
	s <= ss;
	
	
	-- And
	sand(7) <= x(7) and y(7);
	sand(6) <= x(6) and y(6); 
	sand(5) <= x(5) and y(5); 
	sand(4) <= x(4) and y(4); 
	sand(3) <= x(3) and y(3);
	sand(2) <= x(2) and y(2);
	sand(1) <= x(1) and y(1);
	sand(0) <= x(0) and y(0);   
	
	--OR
	sor(7) <= x(7) or y(7);
	sor(6) <= x(6) or y(6); 
	sor(5) <= x(5) or y(5); 
	sor(4) <= x(4) or y(4); 
	sor(3) <= x(3) or y(3);
	sor(2) <= x(2) or y(2);
	sor(1) <= x(1) or y(1);
	sor(0) <= x(0) or y(0);   
	
	--LDA
	slda <= y;
	
	--NOT
	snot <= not x;
	
	
	
	--MUX
	ss <= slda when ula_op = "000" else 
	sadd when ula_op = "001" else
	sor when ula_op = "010" else
	sand when ula_op = "011" else
	snot when ula_op = "100" else
	(others => 'Z');
	
	--Flags
	--Flag N (numero negativo)
	flags_nz (1) <= ss(7);
	
	--Falg Z (s em zero)
	flags_nz(0) <= not(ss(7) or ss(6) or ss(5) or ss(4) or ss(3) or ss(2) or ss(1) or ss(0));
	
	
  	u_adder : fadder8 port map(x, y,'0',sadd, saddoverflow);
	
end architecture aluinterna;

-------------fadder8---------------------------------------

    -- FADDER 8 std_logics
    -- 27/10/23
library IEEE;
use IEEE.std_logic_1164.all;

entity fadder8 is
    port(
        a   : in std_logic_vector (7 downto 0);
        b   : in std_logic_vector (7 downto 0);
        cin : in std_logic;
        s   : out std_logic_vector (7 downto 0);
        cout : out std_logic
    );
end entity;

architecture comportamento of fadder8 is
    
    component fadder
        Port(
            a    : in  std_logic;
            b    : in  std_logic;
            cin  : in  std_logic;
            cout : out std_logic;
            s    : out std_logic
        );
    end component;
    
    signal carry : std_logic_vector (6 downto 0); --Leva o carryout da posicao anterior para o carryin da proxima
    
    begin
        FA0 : fadder port map ( a(0), b(0), cin,      carry(0), s(0) );
        FA1 : fadder port map ( a(1), b(1), carry(0), carry(1), s(1) );
        FA2 : fadder port map ( a(2), b(2), carry(1), carry(2), s(2) );
        FA3 : fadder port map ( a(3), b(3), carry(2), carry(3), s(3) );
        FA4 : fadder port map ( a(4), b(4), carry(3), carry(4), s(4) );
        FA5 : fadder port map ( a(5), b(5), carry(4), carry(5), s(5) );
        FA6 : fadder port map ( a(6), b(6), carry(5), carry(6), s(6) );
        FA7 : fadder port map ( a(7), b(7), carry(6), cout,     s(7) );
    
    end architecture;
    
---------------fadder-----------------------------------
--FADDER 1 std_logic
-- 27/10/23
library IEEE;
use IEEE.std_logic_1164.all;

entity fadder is
    port(
        a    : in  std_logic;
        b    : in  std_logic;
        cin  : in  std_logic;
        cout : out std_logic;
        s    : out std_logic
    );
end entity;

architecture comp of fadder is
    --Nenhum outro componente ou sinais
begin
    s <= (a xor b) xor cin;
    cout <= (a and b)   or 
            (a and cin) or 
            (b and cin);
end architecture;


--------------regCarga8b-------------------------------

library ieee;   
use ieee.std_logic_1164.all;

entity regCarga8b is
    port(
        d : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        pr, cl : in std_logic;
        nrw : in std_logic;
        s : out std_logic_vector(7 downto 0)
        );
end entity;

architecture reg8std_logic of regCarga8b is
    component regCarga1b is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic
            );
    end component;
    
begin
    -- instâncias de regCarga1std_logic (4 vezes)
    u_reg0 : regCarga1b  port map(d(0), clk, pr, cl, nrw, s(0));
    u_reg1 : regCarga1b   port map(d(1), clk, pr, cl, nrw, s(1));
    u_reg2 : regCarga1b  port map(d(2), clk, pr, cl, nrw, s(2));
    u_reg3 : regCarga1b  port map(d(3), clk, pr, cl, nrw, s(3));
    u_reg4 : regCarga1b  port map(d(4), clk, pr, cl, nrw, s(4));
    u_reg5 : regCarga1b  port map(d(5), clk, pr, cl, nrw, s(5));
    u_reg6 : regCarga1b  port map(d(6), clk, pr, cl, nrw, s(6));
    u_reg7 : regCarga1b  port map(d(7), clk, pr, cl, nrw, s(7));
    -- como alternativa e sugestão, é possível trocar as 4 linhas anteriores
    -- por um generate do VHDL!
end architecture;

-------------------regCarga2b------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity regCarga2b is
    port(
        d : in std_logic_vector(1 downto 0);
        clk : in std_logic;
        pr, cl : in std_logic;
        nrw : in std_logic;
        s : out std_logic_vector(1 downto 0)
        );
end entity;

architecture reg2std_logic of regCarga2b is
    component regCarga1b is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic
            );
    end component;
    
begin
    -- instâncias de regCarga1std_logic (4 vezes)
    u_reg0 : regCarga1b port map(d(0), clk, cl, pr, nrw, s(0));
    u_reg1 : regCarga1b port map(d(1), clk, pr, cl, nrw, s(1));
    -- como alternativa e sugestão, é possível trocar as 4 linhas anteriores
    -- por um generate do VHDL!
end architecture;

------------------regCarga1b--------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity regCarga1b is
    port(
        d : in std_logic;
        clk : in std_logic;
        pr, cl : in std_logic;
        nrw : in std_logic;
        s : out std_logic
        );
end entity;

architecture reg1std_logic of regCarga1b is
    component ffd is
        port(
            d      : in std_logic;
            clk    : in std_logic;
            pr, cl : in std_logic;
            q, nq  : out std_logic
            );
    end component;
    
    signal datain, dataout : std_logic;
    
    begin
    -- envio de dataout para saída s
    s <= dataout;
    
    -- multiplexador
    -- nrw = 1 -> entrada principal de interface d
    -- nrw = 0 -> saida temporária dataout (mantém estado)
    datain <= d when nrw = '1' else dataout;
    
    -- instância do reg
    u_reg : ffd port map(datain, clk, pr, cl, dataout);
    
end architecture;

---------flipflops----------------

-- FlipFlop JK ======================================================
library ieee;
use ieee.std_logic_1164.all; -- std_logic para detectar erros

entity ffjk is
    port(
        j, k   : in std_logic;
        clk    : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );
end entity;

architecture latch of ffjk is
    signal sq  : std_logic := '0'; -- opcional -> valor inicial
    signal snq : std_logic := '1';
begin

    q  <= sq;
    nq <= snq;

    u_ff : process (clk, pr, cl)
    begin
        -- pr = 0 e cl = 0 -> Desconhecido
        if (pr = '0') and (cl = '0') then
            sq  <= 'X';
            snq <= 'X';
            -- prioridade para cl
            elsif (pr = '1') and (cl = '0') then
                sq  <= '0';
                snq <= '1';
                -- tratamento de pr
                elsif (pr = '0') and (cl = '1') then
                    sq  <= '1';
                    snq <= '0';
                    -- pr e cl desativados
                    elsif (pr = '1') and (cl = '1') then
                        if falling_edge(clk) then
                            -- jk = 00 -> mantém estado
                            if    (j = '0') and (k = '0') then
                                sq  <= sq;
                                snq <= snq;
                            -- jk = 01 -> q = 0
                            elsif (j = '0') and (k = '1') then
                                sq  <= '0';
                                snq <= '1';
                            -- jk = 01 -> q = 1
                            elsif (j = '1') and (k = '0') then
                                sq  <= '1';
                                snq <= '0';
                            -- jk = 11 -> q = !q
                            elsif (j = '1') and (k = '1') then
                                sq  <= not(sq);
                                snq <= not(snq);
                            -- jk = ?? -> falha
                            else
                                sq  <= 'U';
                                snq <= 'U';
                            end if;
                        end if;
            else
                sq  <= 'X';
                snq <= 'X';
        end if;
    end process;

end architecture;



-- FlipFlop D =======================================================
library ieee;
use ieee.std_logic_1164.all; -- std_logic para detectar erros

entity ffd is
    port(
        d      : in std_logic;
        clk    : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );
end entity;

architecture latch of ffd is
    component ffjk is
        port(
            j, k   : in std_logic;
            clk    : in std_logic;
            pr, cl : in std_logic;
            q, nq  : out std_logic
        );
    end component;

    signal sq  : std_logic := '0'; -- opcional -> valor inicial
    signal snq : std_logic := '1';
    signal nj  : std_logic;
begin

    u_td : ffjk port map(d, nj, clk, pr, cl, q, nq);
    nj <= not(d);

end architecture;



-- FlipFlop T =======================================================
library ieee;
use ieee.std_logic_1164.all; -- std_logic para detectar erros

entity fft is
    port(
        t      : in std_logic;
        clk    : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );
end entity;

architecture latch of fft is
    component ffjk is
        port(
            j, k   : in std_logic;
            clk    : in std_logic;
            pr, cl : in std_logic;
            q, nq  : out std_logic
        );
    end component;

    signal sq  : std_logic := '0'; -- opcional -> valor inicial
    signal snq : std_logic := '1';
begin

    u_td : ffjk port map(t, t, clk, pr, cl, q, nq);

end architecture;
	
	    
		    
