--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2018
--
-- Miguel Arconada Manteca        miguel.arconada@estudiante.uam.es
-- Alberto Gonz�lez Klein         alberto.gonzalezk@estudiante.uam.es
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode   : in  std_logic_vector (5 downto 0); -- Codigo de operacion de la instruccion
      -- Seniales para el PC
      Branch   : out  std_logic;                    -- 1=Ejecutandose instruccion branch
      Jump     : out  std_logic;                    -- 1=Ejecutandose instruccion jump
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic;                    -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic;                    -- 1=Escribir la memoria
      MemRead  : out  std_logic;                    -- L1=eer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                      -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0);  -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic;                    -- 1=Escribir registro
      RegDst   : out  std_logic                     -- 0=Reg. destino es rt, 1=rd
   );
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_ADDI   : t_opCode := "001000";
   constant OP_JUMP   : t_opCode := "000010";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";

   -- Codigos para ALUOp
   constant RTYPE : std_logic_vector (2 downto 0) := "000";
   constant BEQ   : std_logic_vector (2 downto 0) := "001";
   constant ADDI  : std_logic_vector (2 downto 0) := "010";
   constant MEM   : std_logic_vector (2 downto 0) := "011";
   constant LUI   : std_logic_vector (2 downto 0) := "100";

begin
   
   process(OPCode)
   begin
      case OPCode is
         when OP_RTYPE  =>
            RegDst   <= '1';
            Branch   <= '0';
            MemRead  <= '-';
            MemtoReg <= '0';
            ALUOp    <= RTYPE;
            MemWrite <= '0';
            ALUSrc   <= '0';
            RegWrite <= '1';
	        Jump     <= '0';
		when OP_ADDI =>
			Branch    <= '0';
			Jump      <= '0';
			MemToReg  <= '0';
			MemWrite  <= '0';
			MemRead   <= '-'; 
			ALUSrc    <= '1';
			ALUOp     <= ADDI;
			RegWrite  <= '1';
			RegDst    <= '0';
         when OP_BEQ  =>
            RegDst   <= '0';
            Branch   <= '1';
            MemRead  <= '-';
            MemtoReg <= '0';
            ALUOp    <= BEQ;
            MemWrite <= '0';
            ALUSrc   <= '0';
            RegWrite <= '0';
	    Jump     <= '0';
         when OP_SW  =>
            RegDst   <= '0';
            Branch   <= '0';
            MemRead  <= '0';
            MemtoReg <= '0';
            ALUOp    <= MEM;
            MemWrite <= '1';
            ALUSrc   <= '1';
            RegWrite <= '0'; 
            Jump     <= '0';
         when OP_LW  =>
            RegDst   <= '0';
            Branch   <= '0';
            MemRead  <= '1';
            MemtoReg <= '1';
            ALUOp    <= MEM;
            MemWrite <= '0';
            ALUSrc   <= '1';
            RegWrite <= '1';
            Jump     <= '0'; 
         when OP_LUI  =>
            RegDst   <= '0';
            Branch   <= '0';
            MemRead  <= '-';
            MemtoReg <= '0';
            ALUOp    <= LUI;
            MemWrite <= '0';
            ALUSrc   <= '1';
            RegWrite <= '1';
	    Jump     <= '0'; 
         when OP_JUMP =>   
            RegDst   <= '-';
            Branch   <= '0';
            MemRead  <= '-';
            MemtoReg <= '0';
            ALUOp    <= "---";
            MemWrite <= '0';
            ALUSrc   <= '-';
            RegWrite <= '0';
	    Jump     <= '1';      
         when others =>
            RegDst   <= '0';
            Branch   <= '0';
            MemRead  <= '-';
            MemtoReg <= '0';
            ALUOp    <= "---";
            MemWrite <= '0';
            ALUSrc   <= '-';
            RegWrite <= '0';

      end case;
   end process;

end architecture;
