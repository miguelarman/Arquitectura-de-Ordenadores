--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2018-19
--
-- Miguel Arconada Manteca        miguel.arconada@estudiante.uam.es
-- Alberto Gonz�lez Klein         alberto.gonzalezk@estudiante.uam.es
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic;                      -- Reloj activo flanco subida
      Reset       : in  std_logic;                      -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr       : out std_logic_vector(31 downto 0);  -- Direccion
      IDataIn     : in  std_logic_vector(31 downto 0);  -- Dato leido
      -- Data memory
      DAddr       : out std_logic_vector(31 downto 0);  -- Direccion
      DRdEn       : out std_logic;                      -- Habilitacion lectura
      DWrEn       : out std_logic;                      -- Habilitacion escritura
      DDataOut    : out std_logic_vector(31 downto 0);  -- Dato escrito
      DDataIn     : in  std_logic_vector(31 downto 0)   -- Dato leido
   );
end processor;

architecture rtl of processor is 

   --Se�ales para instanciar ALU
   signal BranchSum  : std_logic_vector (31 downto 0);
   signal OpA        : std_logic_vector (31 downto 0);  -- Operando A
   signal OpB        : std_logic_vector (31 downto 0);  -- Operando B
   signal Control    : std_logic_vector (3 downto 0);   -- Codigo de control=op. a ejecutar
   signal Result     : std_logic_vector (31 downto 0);  -- Resultado
   signal ZFlag      : std_logic;                       -- Flag Z
   
   --Se�ales para instanciar ALUcontrol
   signal ALUOp      : std_logic_vector (2 downto 0);   -- Codigo control desde la unidad de control
   signal Funct      : std_logic_vector (5 downto 0);   -- Campo "funct" de la instruccion
   signal ALUControl : std_logic_vector (3 downto 0);   -- Define operacion a ejecutar por ALU

   --Se�ales para instanciar el banco de registros
   signal A1         : std_logic_vector(4 downto 0);    -- Direcci�n para el puerto Rd1
   signal Rd1        : std_logic_vector(31 downto 0);   -- Dato del puerto Rd1
   signal A2         : std_logic_vector(4 downto 0);    -- Direcci�n para el puerto Rd2
   signal Rd2        : std_logic_vector(31 downto 0);   -- Dato del puerto Rd2
   signal A3         : std_logic_vector(4 downto 0);    -- Direcci�n para el puerto Wd3
   signal Wd3        : std_logic_vector(31 downto 0);   -- Dato de entrada Wd3
   signal We3        : std_logic;                       -- Habilitaci�n de la escritura de Wd3

   --Se�ales para instanciar la unidad de control
   signal OpCode     : std_logic_vector (5 downto 0);
   signal Branch     : std_logic;                       -- 1=Ejecutandose instruccion branch
   signal MemToReg   : std_logic;                       -- 1=Escribir en registro la salida de la mem.
   signal MemWrite   : std_logic;                       -- Escribir la memoria
   signal MemRead    : std_logic;                       -- Leer la memoria
   signal ALUSrc     : std_logic;                       -- 0=oper.B es registro, 1=es valor inm.
   signal RegWrite   : std_logic;                       -- 1=Escribir registro
   signal RegDst     : std_logic;                       -- 0=Reg. destino es rt, 1=rd
   signal Jump       : std_logic;                       -- 1=Ejecutandose instruccion jump

   --Se�ales intermedias
   signal NextPC     : std_logic_vector(31 downto 0);   -- Guarda el siguiente valor de PC
   signal PC         : std_logic_vector(31 downto 0);   -- Guarda el valor actual de PC
   signal PCPlus4    : std_logic_vector(31 downto 0);   -- Guarda el valor actual de PC mas 4
   signal ExtSigno   : std_logic_vector(31 downto 0);   -- Guarda los 16 ultimos bits de la instruccion extendido de signo
   signal JumpSum    : std_logic_vector(31 downto 0);   -- Guarda la direccion de salto de jump
   
   --Declaraci�n de ALU para instanciarla
   component alu 
   port (
      OpA     : in  std_logic_vector (31 downto 0);     -- Operando A
      OpB     : in  std_logic_vector (31 downto 0);     -- Operando B
      Control : in  std_logic_vector ( 3 downto 0);     -- Codigo de control=op. a ejecutar
      Result  : out std_logic_vector (31 downto 0);     -- Resultado
      ZFlag   : out std_logic                           -- Flag Z
   );
   end component;


   --Declaraci�n de ALUcontrol para instanciarla
   component alu_control
   port (
      -- Entradas:
      ALUOp      : in std_logic_vector (2 downto 0);    -- Codigo control desde la unidad de control
      Funct      : in std_logic_vector (5 downto 0);    -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0)    -- Define operacion a ejecutar por ALU
   );
   end component;


   --Declaraci�n del banco de registros para instanciarlo
   component reg_bank
   port (
      Clk        : in std_logic;                        -- Reloj activo en flanco de subida
      Reset      : in std_logic;                        -- Reset as�ncrono a nivel alto
      A1         : in std_logic_vector(4 downto 0);     -- Direcci�n para el puerto Rd1
      Rd1        : out std_logic_vector(31 downto 0);   -- Dato del puerto Rd1
      A2         : in std_logic_vector(4 downto 0);     -- Direcci�n para el puerto Rd2
      Rd2        : out std_logic_vector(31 downto 0);   -- Dato del puerto Rd2
      A3         : in std_logic_vector(4 downto 0);     -- Direcci�n para el puerto Wd3
      Wd3        : in std_logic_vector(31 downto 0);    -- Dato de entrada Wd3
      We3        : in std_logic                         -- Habilitaci�n de la escritura de Wd3
   ); 
   end component;


   --Declaraci�n de la unidad de control para instanciarla
   component control_unit
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode     : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch     : out  std_logic;                      -- 1=Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg   : out  std_logic;                      -- 1=Escribir en registro la salida de la mem.
      MemWrite   : out  std_logic;                      -- Escribir la memoria
      MemRead    : out  std_logic;                      -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc     : out  std_logic;                      -- 0=oper.B es registro, 1=es valor inm.
      ALUOp      : out  std_logic_vector (2 downto 0);  -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite   : out  std_logic;                      -- 1=Escribir registro
      RegDst     : out  std_logic                       -- 0=Reg. destino es rt, 1=rd
   );
   end component;

begin

   --Port map para la instanciaci�n de ALU
   alu_pm: alu PORT MAP (
      OpA        => OpA,
      OpB        => OpB,
      Result     => Result,
      ZFlag      => ZFlag,
      Control    => Control
   );

   --Port map para la instanciaci�n de ALUcontrol
   alu_control_pm: alu_control PORT MAP (
      AluOp      => AluOp,
      Funct      => Funct,
      AluControl => AluControl
   );

   --Port map para la instanciaci�n de la unidad de control
   control_unit_pm: control_unit PORT MAP (
       OpCode    => OpCode,
       Branch    => Branch,
       MemToReg  => MemToReg,
       MemWrite  => MemWrite,
       MemRead   => MemRead,
       AluSrc    => AluSrc,
       AluOp     => AluOp,
       RegWrite  => RegWrite,
       RegDst    => RegDst
    );

    --Port map para la instanciaci�n del banco de registros
    reg_bank_pm: reg_bank PORT MAP (
       Clk       => Clk,
       Reset     => Reset,
       A1        => A1,
       Rd1       => Rd1,
       A2        => A2,
       Rd2       => Rd2,
       A3        => A3,
       Wd3       => Wd3,
       We3       => We3
    );

   procesador: process(Clk,Reset)
   begin
      --Contador de programa
      if Reset = '1' then
         PC <= x"00000000";
      elsif rising_edge(Clk) then
	 PC <= NextPC;
      end if;

   end process;

   --C�lculo del PC actual m�s 4
   PCPlus4 <= PC + 4;
   
   --Conexi�n de la memoria de instrucciones con el PC
   IAddr   <= PC;
	   
   --Actualizaci�n del valor del contador de programa
   NextPC  <= (PC + 4 + BranchSum) when (Branch = '1') and (ZFlag = '1') else
	      JumpSum when (Jump = '1') else
              PC + 4;

   --Extensi�n de signo y desplazamiento de dos bits a la izquierda de los 16 �ltimos bits de la instrucci�n
   BranchSum(31 downto 18) <= (others => IDataIn(15));
   BranchSum(17 downto 2)  <= IDataIn(15 downto 0);
   BranchSum(1 downto 0)   <= "00";

   --C�lculo de la direcci�n de salto en caso de Jump
   JumpSum(31 downto 28)   <= PCPlus4(31 downto 28);
   JumpSum(27 downto 2)    <= IDataIn(25 downto 0);
   JumpSum(1 downto 0)     <= "00";

   --Asignaci�n de las distintas partes de la instrucci�n
   OpCode <= IDataIn(31 downto 26);
   A1     <= IDataIn(25 downto 21);
   A2     <= IDataIn(20 downto 16);

   --Multiplexor de A3
   A3     <= IDataIn(20 downto 16) when RegDst = '0' else
             IDataIn(15 downto 11); 
   Funct  <= IDataIn(5 downto 0);

   --Extensi�n de signo de los �ltimos 16 bits de la instrucci�n
   ExtSigno(31 downto 16) <= (others => IDataIn(15));
   ExtSigno(15 downto 0)  <= IDataIn(15 downto 0);
   
   --Conexi�n del We del banco de registros con la se�al RegWrite de la unidad de control
   We3 <= RegWrite;

   --Conexi�n de las se�ales de la ALU
   OpA     <= Rd1;

   --Multiplexor de OpB
   OpB     <= Rd2 when ALUSrc = '0' else 
              ExtSigno;
   Control <= ALUcontrol;

   --Conexi�n de las se�ales de la memoria de datos
   DAddr    <= Result;
   DDataOut <= Rd2;
   DWrEn    <= MemWrite;
   DRdEn    <= MemRead;

   --Multiplexor de Wd3    
   Wd3 <= Result when MemToReg = '0' else
          DDataIn;

end architecture;
