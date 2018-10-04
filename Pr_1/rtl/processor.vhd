--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2018-19
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 

   --Señales para instanciar ALU
   signal BranchSum : std_logic_vector (31 downto 0);
   signal OpA     : std_logic_vector (31 downto 0); -- Operando A
   signal OpB     : std_logic_vector (31 downto 0); -- Operando B
   signal Control : std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
   signal Result  : std_logic_vector (31 downto 0); -- Resultado
   signal ZFlag   : std_logic;                       -- Flag Z
   
   --Señales para instanciar ALUcontrol
   signal ALUOp  : std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
   signal Funct  : std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
   signal ALUControl : std_logic_vector (3 downto 0); -- Define operacion a ejecutar por ALU

   --Señales para instanciar el banco de registros
   --signal Clk   : std_logic; -- Reloj activo en flanco de subida
   --signal Reset : std_logic; -- Reset asíncrono a nivel alto
   signal A1    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
   signal Rd1   : std_logic_vector(31 downto 0); -- Dato del puerto Rd1
   signal A2    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
   signal Rd2   : std_logic_vector(31 downto 0); -- Dato del puerto Rd2
   signal A3    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
   signal Wd3   : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
   signal We3   : std_logic; -- Habilitación de la escritura de Wd3

   --Señales para instanciar la unidad de control
   signal OpCode : std_logic_vector (5 downto 0);
   signal Branch : std_logic; -- 1=Ejecutandose instruccion branch
   signal MemToReg : std_logic; -- 1=Escribir en registro la salida de la mem.
   signal MemWrite : std_logic; -- Escribir la memoria
   signal MemRead  : std_logic; -- Leer la memoria
   signal ALUSrc : std_logic; -- 0=oper.B es registro, 1=es valor inm.
   signal RegWrite : std_logic; -- 1=Escribir registro
   signal RegDst   : std_logic;  -- 0=Reg. destino es rt, 1=rd

   --Señales intermedias
   signal NextPC         : std_logic_vector(31 downto 0);
   signal PC             : std_logic_vector(31 downto 0);
   signal ExtensionSigno : std_logic_vector(31 downto 0);
   
   --Declaración de ALU para instanciarla
   component alu 
   port (
      OpA     : in  std_logic_vector (31 downto 0); -- Operando A
      OpB     : in  std_logic_vector (31 downto 0); -- Operando B
      Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
      Result  : out std_logic_vector (31 downto 0); -- Resultado
      ZFlag   : out std_logic                       -- Flag Z
   );
   end component;


   --Declaración de ALUcontrol para instanciarla
   component alu_control
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
   end component;


   --Declaración del banco de registros para instanciarlo
   component reg_bank
   port (
      Clk   : in std_logic; -- Reloj activo en flanco de subida
      Reset : in std_logic; -- Reset asíncrono a nivel alto
      A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
      Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
      A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
      Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
      A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
      Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
      We3   : in std_logic -- Habilitación de la escritura de Wd3
   ); 
   end component;


   --Declaración de la unidad de control para instanciarla
   component control_unit
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
   );
   end component;


   begin


   --Port map para la instanciación de ALU
   alu_pm: alu PORT MAP (
      OpA => OpA,
      OpB => OpB,
      Result => Result,
      ZFlag => ZFlag,
      Control => Control
   );

   --Port map para la instanciación de ALUcontrol
   alu_control_pm: alu_control PORT MAP (
      AluOp => AluOp,
      Funct => Funct,
      AluControl => AluControl
   );

   --Port map para la instanciación de la unidad de control
   control_unit_pm: control_unit PORT MAP (
       OpCode => OpCode,
       Branch => Branch,
       MemToReg => MemToReg,
       MemWrite => MemWrite,
       MemRead => MemRead,
       AluSrc => AluSrc,
       AluOp => AluOp,
       RegWrite => RegWrite,
       RegDst => RegDst
    );

    --Port map para la instanciación del banco de registros
    reg_bank_pm: reg_bank PORT MAP (
       Clk => Clk,
       Reset => Reset,
       A1 => A1,
       Rd1 => Rd1,
       A2 => A2,
       Rd2 => Rd2,
       A3 => A3,
       Wd3 => Wd3,
       We3 => We3
    );

procesador: process(Clk,Reset)
    begin
	--Contador de programa
	if Reset = '1' then
	   PC <=x"00000000";
	elsif rising_edge(Clk) then
	   PC <= NextPC;
        end if;
    end process;
	   
--Actualización del valor del contador de programa
NextPC <= (PC + 4 + BranchSum) when (Branch = '1') and (ZFlag = '1') else
          PC + 4;

--Extensión de signo y desplazamiento de dos bits a la izquierda de los 16 últimos bits de la instrucción
BranchSum(31 downto 18) <= (others => IDataIn(15));
BranchSum(17 downto 2) <= IDataIn(15 downto 0);
BranchSum(1 downto 0) <= "00";

IAddr <= PC;
We3 <= RegWrite;
OpCode <= IDataIn(31 downto 26);
A1 <= IDataIn(25 downto 21);
A2 <= IDataIn(20 downto 16);

--Multiplexor de A3
A3 <= IDataIn(20 downto 16) when RegDst = '0' else
      IDataIn(15 downto 11); 

Funct <= IDataIn(5 downto 0);
OpA <= Rd1;

--Multiplexor de OpB
ExtensionSigno(31 downto 16) <=(others => IDataIn(15));
ExtensionSigno(15 downto 0) <= IDataIn(15 downto 0);

OpB <= Rd2 when ALUSrc = '0' else ExtensionSigno;

Control <= ALUcontrol;
DAddr <= Result;
DDataOut <= Rd2;
DWrEn <= MemWrite;
DRdEn <= MemRead;

--Multiplexor de Wd3    
Wd3 <= Result when MemToReg = '0' else
       DDataIn;

end architecture;
