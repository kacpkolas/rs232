----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.05.2024 13:28:49
-- Design Name: 
-- Module Name: tb - Behavioral
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

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is

component receiver is  
 Port ( clk_i : in STD_LOGIC; 
 rst_i : in STD_LOGIC;
 RXD_i : in STD_LOGIC;
TXD_o : out STD_LOGIC);
end component;

signal clk_i : std_logic:='0';
signal rst_i: std_logic:='0';
signal RXD_i : std_logic:='1';
signal TXD_o: std_logic;

signal znak1:std_logic_vector(9 downto 0):="1010001100";
signal znak2: std_logic_vector(9 downto 0):="1010001100";

begin

dut: receiver port map(
clk_i => clk_i,
rst_i => rst_i,
RXD_i => RXD_i,
TXD_o => TXD_o
);

clk_i <= not clk_i after 5ns;

    
    stim: process
    begin
    wait for 50ns;
    for i in znak1'range loop
        RXD_i<=znak1(i);
        wait for 104us;
    end loop;
    RXD_i <='1';
    wait for 2ms;
    for i in znak1'range loop
        RXD_i <=znak2(i);
        wait for 104us;
    end loop;
    RXD_i <= '1';
    wait;
    end process stim;
    
end Behavioral;
