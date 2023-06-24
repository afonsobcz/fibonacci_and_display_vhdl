
library ieee, display_utils;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use display_utils.display.all;

entity fsm is
    -- Frequência de Entrada
    generic(input_freq  :   integer := 50e6); -- 50e6 ciclos para 1 segundo

    -- Interfaces da máquina de estados
    port (
	 LEDR					:		inout std_logic_vector(0 downto 0) := "0";
        clk     		:   in      std_logic;
        nRst    		:   in      std_logic;
		  HEX0				:	out 	std_logic_vector(0 to 6);
		HEX1				:	out 	std_logic_vector(0 to 6);
		HEX2				:	out 	std_logic_vector(0 to 6);
		HEX3				:	out 	std_logic_vector(0 to 6);
		HEX4				:	out 	std_logic_vector(0 to 6);
		HEX5				:	out 	std_logic_vector(0 to 6)
		
	
    );
end entity fsm;

architecture rtl of fsm is

    -- Quantidade de ciclos para gerar um segundo
    constant    tempo    :   integer := input_freq;

    -- Estados
    type fsm_state is (s0, s1, s2, s3, s4, s5); -- estados utilizados
    signal estado       : fsm_state := s0; -- variavel do tipo fsm_state controla o estado atual
    signal contador     : integer range 0 to tempo; -- sinal para contagem do clock
	 signal current      : integer range 0 to 999999 := 0; -- valor a ser mostrado no display (valor atual do fibonacci)
	 signal previous1      : integer range 0 to 999999 := 0; -- sinal auxiliar para armazenar o valor anterior
	 signal previous2      : integer range 0 to 999999 := 0;-- sinal auxiliar para armazenar o valor anteanterior
	 signal digits 		: 	display_vector(5 downto 0); -- sinal do tipo necessario para utilizar a biblioteca do display, 6 displays utilizados

    
begin

   fsm: process(clk, nRst) is        
   begin
    if rising_edge(clk) then
        if nRst = '0' then -- Botao resete, reseta os sinais auxiliares e o estado inicial
            estado <= s0;
            contador <= 0;
				previous1 <= 1;
				previous2 <= 0;
        else
				-- Incrementa o contador
            contador <= contador + 1; -- incrementa o contador a cada borda de subida
				
				
            case estado is
                -- Estado 0 reseta os valores dos sinais auxiliares, esse estado só é executado uma vez (exceto qd resetado)
					 when s0 =>
                	contador <= 0;
						previous1 <= 1;
						previous2 <= 0;
						estado <= s1; -- vai ao estado s1
                  
						  
						  
                when s1 => -- Estado 1 Verifica se passou 1 segundo, se sim zera o contador e passa para o estado 2
                    if contador >= tempo - 1 then
								LEDR <= not LEDR;
                        contador <= 0;								
								estado <= s2;							
                    end if;

                -- Estado 2
                when s2 => -- logica de fibonacci, atual recebe anterior e anteanterior, e vai ao estado 3
                     current <= previous1 + previous2;
                     estado <= s3;
							
							
                    
                -- Estado 3
                when s3 => -- atualiza valor do  anteanterior
                     previous2 <= previous1;
                     estado <= s4;
                    

                -- Estado 4  
                when s4 => -- atualiza valor do anterior
                     previous1 <= current;
                     estado <= s5;
                    
					 -- Estado 5
				  	when s5 => -- verifica se o valor atual chegou ao limite, se sim vai ao estado zero (reset) se não vai ao estado 1 (continua a contagem) 
                    if current >= 832040 - 1 then
						  estado <= s0;
						  else
						  estado <= s1;
						  end if;
						  
				  
                    
                    
            
            end case;
            
        end if;
    end if;
   end process fsm;
    -- valores em hexadecimal para cada display
	HEX0 <= digits(0);
	HEX1 <= digits(1);
	HEX2 <= digits(2);
	HEX3 <= digits(3);
	HEX4 <= digits(4);
	HEX5 <= digits(5);
	digits <= display(current, 6, 10, anode); -- q= valor, 4=displapys, 10, anode  -- atualiza os displays com o valor atual

    
    
end architecture rtl;