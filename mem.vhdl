--neander modulo MEM
library IEEE;
use IEEE.std_logic_1164.all;

entity moduloMEM is
    port(
        rst, clk : in std_logic;
        nbarrPC :  in std_logic;
        REM_nrw, MEM_nrw, RDM_nrw :  in std_logic;
        end_PC :  in std_logic_vector(7 downto 0);
        end_Barr :  in std_logic_vector(7 downto 0);
        barramento : inout std_logic_vector(7 downto 0)
        );
end entity;

architecture memoria of moduloMEM is
    --registradores
    component regCarga8b is
        port(
            d : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic_vector(7 downto 0)
            );
    end component;
    --memoria principal
    component as_ram is
        port(   
            addr  : in    std_logic_vector(7 downto 0);
		    data  : inout std_logic_vector(7 downto 0);
		    notrw : in    std_logic;
		    reset : in    std_logic
		    );
    end component;
    
    signal s_mux2rem, s_rem2mem, s_mem2rdm, s_rdm2barr : std_logic_vector(7 downto 0) := (others => 'Z');
    
begin
    
    --mux2x8
    s_mux2rem <= end_PC when nbarrPC = '1' else end_barr;
    
    --Registrador REM
    u_regREM : regCarga8b port map(s_mux2rem, clk, '1', rst, REM_nrw, s_rem2mem);
    
    --memoria
    u_mem : as_ram port map(s_rem2mem, s_mem2rdm, MEM_nrw, rst);
    
    --mux barramento
    barramento <= s_rdm2barr when MEM_nrw = '0' else (others => 'Z');
    
    s_mem2rdm <= barramento when MEM_nrw = '1' else (others => 'Z');
    
    --Registrador RDM
    u_regRDM : regCarga8b port map(s_mem2rdm, clk, '1', rst, RDM_nrw, s_rdm2barr);
    
end architecture;

------------as_ram--------------
-- neander asynchronous simple ram memory
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity as_ram is
	port(
		addr  : in    std_logic_vector(7 downto 0);
		data  : inout std_logic_vector(7 downto 0);
		notrw : in    std_logic;
		reset : in    std_logic
	);
end entity as_ram;

architecture behavior of as_ram is
	type ram_type is array (0 to 255) of std_logic_vector(7 downto 0);
	signal ram : ram_type;
	signal data_out : std_logic_vector(7 downto 0);
begin
	
	rampW : process(notrw, reset, addr, data)
	type binary_file is file of character;
	file load_file : binary_file open read_mode is "neanderram.mem";
	variable char : character;
	begin
		if (reset = '0' and reset'event) then
			-- init ram
			read(load_file, char); -- 0x03 '.'
			read(load_file, char); -- 0x4E 'N'
			read(load_file, char); -- 0x44 'D'
			read(load_file, char); -- 0x52 'R'
			for i in 0 to 255 loop
				if not endfile(load_file) then
						read(load_file, char);
						ram(i) <= std_logic_vector(to_unsigned(character'pos(char),8));
						read(load_file, char);	-- 0x00 orindo de alinhamento 16bits	
				end if; -- if not endfile(load_file) then
			end loop; -- for i in 0 to 255
        else
		    if (reset = '1' and notrw = '1') then
			    -- Write
			    ram(to_integer(unsigned(addr))) <= data;
		    end if; -- reset == '1'
		end if; -- reset == '0'
	end process rampW;

	data <= data_out when (reset = '1' and notrw = '0')
		  else (others => 'Z');

	rampR : process(notrw, reset, addr, data)
	begin
		if (reset = '1' and notrw = '0') then
				-- Read
				data_out <= ram(to_integer(unsigned(addr)));
		end if; -- reset = '1' and notrw = '0'
	end process rampR;
end architecture behavior;
