----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.05.2024 22:14:51
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity receiver is  
 Port ( clk_i : in STD_LOGIC; 
 rst_i : in STD_LOGIC;
 RXD_i : in STD_LOGIC;
TXD_o : out STD_LOGIC);
end receiver;
 --zamys³ rozwiazania - zamiast oddzielnych modu³ów nadajnika i odbiornika, bêdziemy po prostu jednoczesnie przy odbiorze odsy³aæ
--dany bit na wyjscie, zmieniaj¹c wy³¹cznie 6 bit (+20h - 100000)
architecture Behavioral of receiver is
type StateType is (idle, firstread, operate);
signal current_state: StateType:=idle;
signal next_state : StateType:=idle;
signal znak: std_logic_vector(9 downto 0);
signal RXD_old: std_logic;
begin

    seq: process(clk_i, rst_i)
    variable counter1: INTEGER:=0;
    variable counter2: INTEGER:=0;
    variable counter3: INTEGER:=0;
    variable counterShift : INTEGER:=0; --do przesuniêcia o 20h
    variable jakis: boolean:=false;
    
    begin
    if rising_edge(clk_i) then
     
     RXD_old <= RXD_i;
     current_state <= next_state;
                
     if rst_i='1' then 
     current_state <=idle;
     counter1:=0;
     counter2:=0;
    -- counter3:=0;
     counterShift:=0;
     end if;
     
     
     if current_state = firstread then
     counter2:=counter2+1;
                if counter2 = 5208 then  --odczyt szybszy dwukrotnie, zeby trafic w polowe nadanego bitu
                znak<=RXD_i & znak(8 downto 0);
                current_state<=operate; --niekonieczne ale mzoe sie przyuda
                counter2:=0;
                TXD_o <= RXD_i;
                end if;
     counter1:=0;  --zerujemy oba liczniki bo potrzebne to do kolejnej operacji
     
     end if;
         
    if current_state = operate then
    counter1:=counter1+1;
        if counter1 = 10416 and (znak(9)='1' nand znak(0)='0') then --gdy dlugosc znaku i nie mamy jeszcze bitu stopu i startu
        znak <= RXD_i & znak(8 downto 0);
        counter1:=0;  
        counterShift:=counterShift+1;
             if counterShift=6 then --jesli trafimy na 6 bit danych to wymuszamy 1 (odpowiada to za +20h)
            
             if RXD_i='1' then
                    jakis:=true;
                    TXD_o <=RXD_i;
                    else
                    TXD_o<='1';
             end if; --????
             elsif counterShift=7 and jakis=true then
             TXD_o <='1';
             else
             TXD_o <= RXD_i;
             end if;
             
             
             if counterShift = 9 then
             current_state <= idle;
             counterShift := 0;
             jakis:=false;
             end if;
        end if;
  --  counter3:=0;
  
    end if;
    
    if current_state = idle then 
    counterShift:=0;
    --counter3:=counter3+1;
      TXD_o <= '1';  
      znak <= (others=>'1');  
        --if counter3=10416 then --ten licznik opozni wyzerowanie stanu znak, tak aby w drugim komponencie odczyt na pewno byl dobry (nieaktualne)
        --znak<=(others=>'1'); --wyjedynkowanie znaku do kolejnego odczytu (basic jedynka!!!) 
        --counter3:=0;
        --TXD_o <= '1';
        --end if;
   counter2:=0;  --mozliwe ze dwa liczniki by wystarczyly, przerobic
 
   end if;
  
end if;
end process;

comb: process(current_state, RXD_old, RXD_i, znak)

begin

 if (RXD_old xor RXD_i)='1' then
case current_state is
    when idle =>
    next_state <= firstread;
    when firstread =>
    next_state <= operate;
    when operate => 
    if znak(9)='1' and znak(0)='0' then --zmienione dla testu, poprawic
  
    next_state <= idle;
    else
    next_state <= current_state;
   
    end if;
    when others =>
    next_state <= idle;
end case; 
else 
next_state <= current_state; --wazne, zawsze przypisywac jakikolwiek stan jako nastepny

end if;   

end process comb;


end Behavioral;
