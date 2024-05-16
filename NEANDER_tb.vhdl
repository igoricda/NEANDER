-- NEANDER - TestBench ========================================================
-- ghdl -a *.vhdl ; ghdl -r tb_neander --wave=NEANDER_tb.ghw --stop-time=4000ns
library IEEE;
use IEEE.std_logic_1164.all;

entity tb_neander is
end entity tb_neander;

architecture letsdothis of tb_neander is
    constant cicloClock : time := 20 ns;

    component modNeander is
	    port(
            rst   : in std_logic;
            clk   : in std_logic
	    );
    end component modNeander;

    signal rst : std_logic := '1';
    signal clk : std_logic := '0';

begin
    clk <= not(clk) after cicloClock / 2;

    u_neander : modNeander port map(rst, clk);

    process
    begin

        -- reset inicial
        rst <= '0';
        wait for cicloClock;
        rst <= '1';

        wait;

    end process;

end architecture letsdothis; 
