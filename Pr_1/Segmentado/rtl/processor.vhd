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
   signal BranchSum_EX : std_logic_vector (31 downto 0);
   signal OpA_EX       : std_logic_vector (31 downto 0); -- Operando A
   signal OpB_EX       : std_logic_vector (31 downto 0); -- Operando B
   signal Control_EX   : std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
   signal Result_EX    : std_logic_vector (31 downto 0); -- Resultado
   signal Result_MEM    : std_logic_vector (31 downto 0); -- Resultado
   signal Result_WB    : std_logic_vector (31 downto 0); -- Resultado
   signal ZFlag_EX     : std_logic;                       -- Flag Z
   signal ZFlag_MEM     : std_logic;                       -- Flag Z
   
   --Señales para instanciar ALUcontrol
   signal ALUOp_ID  : std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
   signal ALUOp_EX  : std_logic_vector (2 downto 0); -- Codigo control desde la unidad de control
   signal ALUControl_EX : std_logic_vector (3 downto 0); -- Define operacion a ejecutar por ALU

   --Señales para instanciar el banco de registros
   --signal Clk   : std_logic; -- Reloj activo en flanco de subida
   --signal Reset : std_logic; -- Reset asíncrono a nivel alto
   signal A1_ID    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
   signal Rd1_ID   : std_logic_vector(31 downto 0); -- Dato del puerto Rd1
   signal Rd1_EX   : std_logic_vector(31 downto 0); -- Dato del puerto Rd1
   signal A2_ID    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
   signal Rd2_ID   : std_logic_vector(31 downto 0); -- Dato del puerto Rd2
   signal Rd2_EX   : std_logic_vector(31 downto 0); -- Dato del puerto Rd2
   signal Rd2_MEM   : std_logic_vector(31 downto 0); -- Dato del puerto Rd2
   signal A3_ID    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
   signal A3_EX    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
   signal A3_MEM    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
   signal A3_WB    : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
   signal Wd3_ID   : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
   signal Wd3_EX   : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
   signal Wd3_MEM   : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
   signal Wd3_WB   : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
   signal We3_ID   : std_logic; -- Habilitación de la escritura de Wd3
   signal We3_EX   : std_logic; -- Habilitación de la escritura de Wd3
   signal We3_MEM   : std_logic; -- Habilitación de la escritura de Wd3
   signal We3_WB   : std_logic; -- Habilitación de la escritura de Wd3

   --Señales para instanciar la unidad de control
   signal OpCode_ID : std_logic_vector (5 downto 0);
   signal Branch_ID : std_logic; -- 1=Ejecutandose instruccion branch
   signal Branch_EX : std_logic; -- 1=Ejecutandose instruccion branch
   signal Branch_MEM : std_logic; -- 1=Ejecutandose instruccion branch
   signal MemToReg_ID : std_logic; -- 1=Escribir en registro la salida de la mem.
   signal MemToReg_EX : std_logic; -- 1=Escribir en registro la salida de la mem.
   signal MemToReg_MEM : std_logic; -- 1=Escribir en registro la salida de la mem.
   signal MemToReg_WB : std_logic; -- 1=Escribir en registro la salida de la mem.
   signal MemWrite_ID : std_logic; -- Escribir la memoria
   signal MemWrite_EX : std_logic; -- Escribir la memoria
   signal MemWrite_MEM : std_logic; -- Escribir la memoria
   signal MemRead_ID  : std_logic; -- Leer la memoria
   signal MemRead_EX  : std_logic; -- Leer la memoria
   signal MemRead_MEM  : std_logic; -- Leer la memoria
   signal ALUSrc_ID : std_logic; -- 0=oper.B es registro, 1=es valor inm.
   signal ALUSrc_EX : std_logic; -- 0=oper.B es registro, 1=es valor inm.
   signal RegWrite_ID : std_logic; -- 1=Escribir registro
   signal RegWrite_EX : std_logic; -- 1=Escribir registro
   signal RegWrite_MEM : std_logic; -- 1=Escribir registro
   signal RegWrite_WB : std_logic; -- 1=Escribir registro
   signal RegDst_ID   : std_logic;  -- 0=Reg. destino es rt, 1=rd
   signal RegDst_EX   : std_logic;  -- 0=Reg. destino es rt, 1=rd
   signal Jump_ID   : std_logic;  -- 1=Ejecutandose instruccion jump
   signal Jump_EX   : std_logic;  -- 1=Ejecutandose instruccion jump
   signal Jump_MEM   : std_logic;  -- 1=Ejecutandose instruccion jump

   --Señales intermedias
   signal NextPC_IF         : std_logic_vector(31 downto 0);
   signal PC_IF             : std_logic_vector(31 downto 0);
   signal PCPlus4_IF        : std_logic_vector(31 downto 0);
   signal PCPlus4_ID        : std_logic_vector(31 downto 0);
   signal PCPlus4_EX        : std_logic_vector(31 downto 0);
   signal PCPlus4_MEM        : std_logic_vector(31 downto 0);
   signal ExtensionSigno_ID : std_logic_vector(31 downto 0);
   signal ExtensionSigno_EX : std_logic_vector(31 downto 0);
   signal JumpSum_MEM       : std_logic_vector(31 downto 0);
   signal IDataIn_IF        : std_logic_vector(31 downto 0);
   signal IDataIn_EX        : std_logic_vector(31 downto 0);
   signal IDataIn_ID        : std_logic_vector(31 downto 0);
   signal IDataIn_MEM       : std_logic_vector(31 downto 0);
   signal IAddr_IF             : std_logic_vector(31 downto 0);
   signal BranchAddress_EX  : std_logic_vector(31 downto 0);
   signal BranchAddress_MEM : std_logic_vector(31 downto 0);
   signal Funct_EX          : std_logic_vector(5 downto 0);
   signal DDataIn_MEM          : std_logic_vector(31 downto 0);
   signal DDataIn_WB          : std_logic_vector(31 downto 0);
   signal Rt_ID          : std_logic_vector(31 downto 0);
   signal Rt_EX          : std_logic_vector(31 downto 0);
   signal Rd_ID          : std_logic_vector(31 downto 0);
   signal Rd_EX          : std_logic_vector(31 downto 0);
   
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
      OpA => OpA_EX,
      OpB => OpB_EX,
      Result => Result_EX,
      ZFlag => ZFlag_EX,
      Control => Control_EX
   );

   --Port map para la instanciación de ALUcontrol
   alu_control_pm: alu_control PORT MAP (
      AluOp => AluOp_EX,
      Funct => IDataIn(5 downto 0),
      AluControl => AluControl_EX
   );

   --Port map para la instanciación de la unidad de control
   control_unit_pm: control_unit PORT MAP (
       OpCode => OpCode_ID,
       Branch => Branch_ID,
       MemToReg => MemToReg_ID,
       MemWrite => MemWrite_ID,
       MemRead => MemRead_ID,
       AluSrc => AluSrc_ID,
       AluOp => AluOp_ID,
       RegWrite => RegWrite_ID,
       RegDst => RegDst_ID
    );

    --Port map para la instanciación del banco de registros
    reg_bank_pm: reg_bank PORT MAP (
       Clk => Clk,
       Reset => Reset,
       A1 => A1_ID,
       Rd1 => Rd1_ID,
       A2 => A2_ID,
       Rd2 => Rd2_ID,
       A3 => A3_WB,
       Wd3 => Wd3_WB,
       We3 => We3_WB
    );

procesador: process(Clk,Reset)
    begin
	--Contador de programa
	if Reset = '1' then
	   PC_IF <=x"00000000";
	elsif rising_edge(Clk) then
	   PC_IF <= NextPC_IF;
        end if;
    end process;
	   
--Actualización del valor del contador de programa
NextPC_IF <= BranchAddress_MEM when (Branch_MEM = '1') and (ZFlag_MEM = '1') else
	  JumpSum_MEM when (Jump_MEM = '1') else
          PCPlus4_IF;

--Calculo de direccion de branch
BranchAddress_EX <= (ExtensionSigno_EX(29 downto 0) & "00") + PCPlus4_EX;

--Extensión de signo y desplazamiento de dos bits a la izquierda de los 16 últimos bits de la instrucción
BranchSum_EX(31 downto 2) <= ExtensionSigno_EX(29 downto 0);
BranchSum_EX(1 downto 0) <= "00";

--Cuidaoooooooooooooooooo
PCPlus4_IF <= PC_IF + 4;
JumpSum_MEM(31 downto 28) <= PCPlus4_MEM(31 downto 28);
JumpSum_MEM(27 downto 2) <= IDataIn_MEM(25 downto 0);
JumpSum_MEM(1 downto 0) <= "00";

IAddr <= IAddr_IF;
IAddr_IF <= PC_IF;


We3_WB <= RegWrite_WB;
OpCode_ID <= IDataIn_ID(31 downto 26);
A1_ID <= IDataIn_ID(25 downto 21);
A2_ID <= IDataIn_ID(20 downto 16);

--Multiplexor de A3
A3_EX <= IDataIn_EX(20 downto 16) when RegDst_EX = '0' else
      IDataIn_EX(15 downto 11); 

Funct_EX <= IDataIn_EX(5 downto 0);
OpA_EX <= Rd1_EX;

--Multiplexor de OpB
ExtensionSigno_ID(31 downto 16) <=(others => IDataIn_ID(15));
ExtensionSigno_ID(15 downto 0) <= IDataIn_ID(15 downto 0);

OpB_EX <= Rd2_EX when ALUSrc_EX = '0' else ExtensionSigno_EX;


Control_EX <= ALUcontrol_EX;

DAddr <= Result_MEM;
DDataOut <= Rd2_MEM;
DWrEn <= MemWrite_MEM;
DRdEn <= MemRead_MEM;

--Multiplexor de Wd3    
Wd3_WB <= Result_WB when MemToReg_WB = '0' else
       DDataIn_WB;

-- Pipeline IF/ID
pipelineIFID: process(Clk, Reset)
   begin
      if Reset = '1' then
         
      elsif rising_edge(Clk) then
         PCPlus4_IF <= PCPlus4_ID;
         IDataIn_ID <= IDataIn_IF;
      end if;
   end process;


-- Pipeline ID/EX
pipelineIDEX: process(Clk, Reset)
   begin
      if Reset = '1' then
         
      elsif rising_edge(Clk) then
         RegWrite_EX <= RegWrite_ID;
         Branch_EX <= Branch_ID;
         RegDst_EX <= RegDst_ID;
         ALUOp_EX <= ALUOp_ID;
         ALUSrc_EX <= ALUSrc_ID;
         PCPlus4_EX <= PCPlus4_ID;
         Rd1_EX <= Rd1_ID;
         Rd2_EX <= Rd2_ID;
         ExtensionSigno_EX <= ExtensionSigno_ID;
         Rt_EX <= Rt_ID;
         Rd_EX <= Rd_ID;
         IDataIn_EX <= IDataIn_ID;
         A3_EX <= A3_ID;
         Wd3_EX <= Wd3_ID;
         We3_EX <= We3_ID;
      end if;
   end process;

-- Pipeline EX/MEM
pipelineEXMEM: process(Clk, Reset)
   begin
      if Reset = '1' then
         
      elsif rising_edge(Clk) then
         RegWrite_MEM <= RegWrite_EX;
         Branch_MEM <= Branch_EX;
         ZFlag_MEM <= ZFlag_EX;
         Result_MEM <= Result_EX;
         Rd2_MEM <= Rd2_EX;
         IDataIn_MEM <= IDataIn_EX;
         A3_MEM <= A3_EX;
         Wd3_MEM <= Wd3_EX;
         We3_MEM <= We3_EX;
      end if;
   end process;

-- Pipeline MEM/WB
pipelineMEMWB: process(Clk, Reset)
   begin
      if Reset = '1' then
         
      elsif rising_edge(Clk) then
         RegWrite_WB <= RegWrite_MEM;
         DDataIn_WB <= DDataIn_MEM;
         Result_WB <= Result_MEM;
         A3_WB <= A3_MEM;
         Wd3_WB <= Wd3_MEM;
         We3_WB <= We3_MEM;
         DDataIn_WB <= DDataIn_MEM;
      end if;
   end process;

end architecture;
