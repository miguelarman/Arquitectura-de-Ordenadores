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
      ALUOp      : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct      : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is

   subtype t_aluOp   is std_logic_vector (2 downto 0);
   subtype t_control is std_logic_vector (3 downto 0);
   subtype t_funct   is std_logic_vector (5 downto 0);

   -- Codigos para ALUOp
   constant RTYPE    : t_aluOp := "000";
   constant BEQ      : t_aluOp := "001";
   constant ADDI     : t_aluOp := "010";
   constant MEM      : t_aluOp := "011";
   constant LUI      : t_aluOp := "100";


   -- Codigos de control
   constant ALU_OR   : t_control := "0111";   
   constant ALU_NOT  : t_control := "0101";
   constant ALU_XOR  : t_control := "0110";
   constant ALU_AND  : t_control := "0100";
   constant ALU_SUB  : t_control := "0001";
   constant ALU_ADD  : t_control := "0000";
   constant ALU_SLT  : t_control := "1010";
   constant ALU_S16  : t_control := "1101";


   -- Codifcacion de funct
   constant F_ADD    : t_funct := "100000";
   constant F_AND    : t_funct := "100100";
   constant F_OR     : t_funct := "100101";
   constant F_SUB    : t_funct := "100010";
   constant F_XOR    : t_funct := "100110";

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
               when others => ALUControl <= "----";
            end case;
         when BEQ    => ALUControl <= ALU_SUB;
         when ADDI   => ALUControl <= ALU_ADD;
         when MEM    => ALUControl <= ALU_ADD;
         when LUI    => ALUControl <= ALU_S16;
         when others => ALUControl <= "----";
      end case;
   end process;

end architecture;
