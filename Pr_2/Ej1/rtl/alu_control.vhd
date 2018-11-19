--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2018.
--
-- Miguel Arconada Manteca        miguel.arconada@estudiante.uam.es
-- Alberto González Klein         alberto.gonzalezk@estudiante.uam.es
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp      : in  std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct      : in  std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0)  -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is

   -- Codigos para ALUOp
   constant RTYPE : std_logic_vector (2 downto 0) := "000";
   constant BEQ   : std_logic_vector (2 downto 0) := "001";
   constant ADDI  : std_logic_vector (2 downto 0) := "010";
   constant MEM   : std_logic_vector (2 downto 0) := "011";
   constant LUI   : std_logic_vector (2 downto 0) := "100";


   -- Codigos de control
   constant ALU_OR   : std_logic_vector (3 downto 0) := "0111";   
   constant ALU_NOT  : std_logic_vector (3 downto 0) := "0101";
   constant ALU_XOR  : std_logic_vector (3 downto 0) := "0110";
   constant ALU_AND  : std_logic_vector (3 downto 0) := "0100";
   constant ALU_SUB  : std_logic_vector (3 downto 0) := "0001";
   constant ALU_ADD  : std_logic_vector (3 downto 0) := "0000";
   constant ALU_SLT  : std_logic_vector (3 downto 0) := "1010";
   constant ALU_S16  : std_logic_vector (3 downto 0) := "1101";


   -- Codifcacion de funct
   constant F_ADD : std_logic_vector (5 downto 0) := "100000";
   constant F_AND : std_logic_vector (5 downto 0) := "100100";
   constant F_OR  : std_logic_vector (5 downto 0) := "100101";
   constant F_SUB : std_logic_vector (5 downto 0) := "100010";
   constant F_XOR : std_logic_vector (5 downto 0) := "100110";

begin

   process (ALUOp, Funct)
   begin
      case ALUOp is
         when RTYPE  =>
            case Funct is
               when F_ADD  => ALUControl <= ALU_ADD;
               when F_AND  => ALUControl <= ALU_AND;
               when F_OR   => ALUControl <= ALU_OR;
               when F_SUB  => ALUControl <= ALU_SUB;
               when F_XOR  => ALUControl <= ALU_XOR;
               when others => ALUControl <= "1111";
            end case;
         when BEQ    => ALUControl <= ALU_SUB;
         when ADDI   => ALUControl <= ALU_ADD;
         when MEM    => ALUControl <= ALU_ADD;
         when LUI    => ALUControl <= ALU_S16;
         when others => ALUControl <= "1110";
      end case;
   end process;

end architecture;
