--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2018-19
--
-- Miguel Arconada Manteca        miguel.arconada@estudiante.uam.es
-- Alberto González Klein         alberto.gonzalezk@estudiante.uam.es
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic;                          -- Reloj activo flanco subida
      Reset       : in  std_logic;                          -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0);       -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0);       -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0);       -- Direccion
      DRdEn      : out std_logic;                           -- Habilitacion lectura
      DWrEn      : out std_logic;                           -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0);       -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)        -- Dato leido
   );
end processor;

architecture rtl of processor is 

   -------------------------------------------
   --Señales para instanciar los componentes--
   -------------------------------------------

   --Señales para instanciar ALU
   signal OpA_EX        : std_logic_vector (31 downto 0);   -- Operando A
   signal OpB_EX        : std_logic_vector (31 downto 0);   -- Operando B
   signal Control_EX    : std_logic_vector ( 3 downto 0);   -- Codigo de control=op. a ejecutar
   signal Result_EX     : std_logic_vector (31 downto 0);   -- Resultado en EX
   signal Result_MEM    : std_logic_vector (31 downto 0);   -- Resultado en MEM
   signal Result_WB     : std_logic_vector (31 downto 0);   -- Resultado en WB
   signal ZFlag_EX      : std_logic;                        -- Flag Z en EX
   signal ZFlag_MEM     : std_logic;                        -- Flag Z en MEM
   
   --Señales para instanciar ALUcontrol
   signal ALUOp_ID      : std_logic_vector ( 2 downto 0);   -- Codigo control desde la unidad de control en ID
   signal ALUOp_EX      : std_logic_vector ( 2 downto 0);   -- Codigo control desde la unidad de control en EX
   signal ALUControl_EX : std_logic_vector ( 3 downto 0);   -- Define operacion a ejecutar por ALU

   --Señales para instanciar el banco de registros
   signal A1_ID         : std_logic_vector ( 4 downto 0);   -- Dirección para el puerto Rd1
   signal Rd1_ID        : std_logic_vector (31 downto 0);   -- Dato del puerto Rd1 en ID
   signal Rd1_EX        : std_logic_vector (31 downto 0);   -- Dato del puerto Rd1 en EX
   signal A2_ID         : std_logic_vector ( 4 downto 0);   -- Dirección para el puerto Rd2
   signal Rd2_ID        : std_logic_vector (31 downto 0);   -- Dato del puerto Rd2 en ID
   signal Rd2_EX        : std_logic_vector (31 downto 0);   -- Dato del puerto Rd2 en EX
   signal Rd2_MEM       : std_logic_vector (31 downto 0);   -- Dato del puerto Rd2 en MEM
   signal A3_EX         : std_logic_vector ( 4 downto 0);   -- Dirección para el puerto Wd3 en EX
   signal A3_MEM        : std_logic_vector ( 4 downto 0);   -- Dirección para el puerto Wd3 en MEM
   signal A3_WB         : std_logic_vector ( 4 downto 0);   -- Dirección para el puerto Wd3 en WB
   signal Wd3_WB        : std_logic_vector (31 downto 0);   -- Dato de entrada Wd3 em WB
   signal We3_WB        : std_logic;                        -- Habilitación de la escritura de Wd3 en WB

   --Señales para instanciar la unidad de control
   signal OpCode_ID     : std_logic_vector ( 5 downto 0);   -- Codigo de operación de la instrucción
   signal Branch_ID     : std_logic;                        -- 1=Ejecutandose instruccion branch en ID
   signal Branch_EX     : std_logic;                        -- 1=Ejecutandose instruccion branch en EX
   signal Branch_MEM    : std_logic;                        -- 1=Ejecutandose instruccion branch en MEM
   signal MemToReg_ID   : std_logic;                        -- 1=Escribir en registro la salida de la mem. en ID
   signal MemToReg_EX   : std_logic;                        -- 1=Escribir en registro la salida de la mem. en EX
   signal MemToReg_MEM  : std_logic;                        -- 1=Escribir en registro la salida de la mem. en MEM
   signal MemToReg_WB   : std_logic;                        -- 1=Escribir en registro la salida de la mem. en WB
   signal MemWrite_ID   : std_logic;                        -- Escribir la memoria en ID
   signal MemWrite_EX   : std_logic;                        -- Escribir la memoria en EX
   signal MemWrite_MEM  : std_logic;                        -- Escribir la memoria en MEM
   signal MemRead_ID    : std_logic;                        -- Leer la memoria en ID
   signal MemRead_EX    : std_logic;                        -- Leer la memoria en EX
   signal MemRead_MEM   : std_logic;                        -- Leer la memoria en MEM
   signal ALUSrc_ID     : std_logic;                        -- 0=oper.B es registro, 1=es valor inm. en ID
   signal ALUSrc_EX     : std_logic;                        -- 0=oper.B es registro, 1=es valor inm. en EX
   signal RegWrite_ID   : std_logic;                        -- 1=Escribir registro en ID
   signal RegWrite_EX   : std_logic;                        -- 1=Escribir registro en EX
   signal RegWrite_MEM  : std_logic;                        -- 1=Escribir registro en MEM
   signal RegWrite_WB   : std_logic;                        -- 1=Escribir registro en WB
   signal RegDst_ID     : std_logic;                        -- 0=Reg. destino es rt, 1=rd en ID
   signal RegDst_EX     : std_logic;                        -- 0=Reg. destino es rt, 1=rd en EX
   signal Jump_ID       : std_logic;                        -- 1=Ejecutandose instruccion jump en ID
   signal Jump_EX       : std_logic;                        -- 1=Ejecutandose instruccion jump en EX
   signal Jump_MEM      : std_logic;                        -- 1=Ejecutandose instruccion jump en MEM

   --------------------------------------
   --Declaracion de señales intermedias--
   --------------------------------------
   signal NextPC_IF          : std_logic_vector (31 downto 0);  -- Senal que selecciona el PC siguiente entre pc+4 y el PC de salto 
   signal PC_IF              : std_logic_vector (31 downto 0);  -- Contador de programa
   signal PCPlus4_IF         : std_logic_vector (31 downto 0);  -- PC+4 en la etapa IF
   signal PCPlus4_ID         : std_logic_vector (31 downto 0);  -- PC+4 en la etapa ID
   signal PCPlus4_EX         : std_logic_vector (31 downto 0);  -- PC+4 en la etapa EX
   signal ExtensionSigno_ID  : std_logic_vector (31 downto 0);  -- Exension en signo del dato inmediato en ID
   signal ExtensionSigno_EX  : std_logic_vector (31 downto 0);  -- Exension en signo del dato inmediato en EX
   signal JumpAddr_EX        : std_logic_vector (31 downto 0);  -- Valor a sumar para hallar la direccion de salto
   signal JumpAddr_MEM       : std_logic_vector (31 downto 0);  -- Valor a sumar para hallar la direccion de salto
   signal IDataIn_IF         : std_logic_vector (31 downto 0);  -- Instruccion leida en la etapa IF
   signal IDataIn_ID         : std_logic_vector (31 downto 0);  -- Instruccion leida en la etapa EX
   signal IAddr_IF           : std_logic_vector (31 downto 0);  -- Direccion de la que se lee la instruccion en IF
   signal BranchAddress_EX   : std_logic_vector (31 downto 0);  -- Direccion de branch si se da la condicion en EX
   signal BranchAddress_MEM  : std_logic_vector (31 downto 0);  -- Direccion de branch si se da la condicion en MEM
   signal Funct_EX           : std_logic_vector ( 5 downto 0);  -- Campo Funct de la instruccion
   signal DDataIn_MEM        : std_logic_vector (31 downto 0);  -- Dato leido de la memoria en MEM
   signal DDataIn_WB         : std_logic_vector (31 downto 0);  -- Dato leido de la memoria en WB
   signal Rt_ID              : std_logic_vector ( 4 downto 0);  -- Campo Rt de la instruccion en ID
   signal Rt_EX              : std_logic_vector ( 4 downto 0);  -- Campo Rt de la instruccion en EX
   signal Rd_ID              : std_logic_vector ( 4 downto 0);  -- Campo Rd de la instruccion en ID
   signal Rd_EX              : std_logic_vector ( 4 downto 0);  -- Campo Rd de la instruccion en EX
   signal MUX_EX             : std_logic_vector (31 downto 0);  -- Senal que une los multplexores de OpB paa el forwarding
   signal OpCode_EX          : std_logic_vector ( 5 downto 0);  -- Codigo de operación de la instrucción
   signal IFIDWrite          : std_logic;                       -- Senal para parar el primer pipeline
   signal PCWrite            : std_logic;                       -- Senal para parar el PC
   signal EXMEMStop          : std_logic;                       -- Senal para parar el pipeline EX/MEM
   signal IFIDStop           : std_logic;                       -- Senal para parar el pipeline IF/ID
   
   -----------------------------
   --Declaracion de constantes--
   -----------------------------
   constant LW_OPCODE  : std_logic_vector (5 downto 0) := "100011";
   constant BEQ_OPCODE : std_logic_vector (5 downto 0) := "000100";


   ------------------------------------
   --Instanciacion de los componentes--
   ------------------------------------

   --Declaración de ALU para instanciarla
   component alu 
   port (
      OpA        : in  std_logic_vector (31 downto 0);   -- Operando A
      OpB        : in  std_logic_vector (31 downto 0);   -- Operando B
      Control    : in  std_logic_vector ( 3 downto 0);   -- Codigo de control=op. a ejecutar
      Result     : out std_logic_vector (31 downto 0);   -- Resultado
      ZFlag      : out std_logic                         -- Flag Z
   );
   end component;

   --Declaración de ALUcontrol para instanciarla
   component alu_control
   port (
      -- Entradas:
      ALUOp      : in  std_logic_vector ( 2 downto 0);   -- Codigo control desde la unidad de control
      Funct      : in  std_logic_vector ( 5 downto 0);   -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector ( 3 downto 0)    -- Define operacion a ejecutar por ALU
   );
   end component;


   --Declaración del banco de registros para instanciarlo
   component reg_bank
   port (
      Clk        : in  std_logic;                       -- Reloj activo en flanco de subida
      Reset      : in  std_logic;                       -- Reset asíncrono a nivel alto
      A1         : in  std_logic_vector ( 4 downto 0);  -- Dirección para el puerto Rd1
      Rd1        : out std_logic_vector (31 downto 0);  -- Dato del puerto Rd1
      A2         : in  std_logic_vector ( 4 downto 0);  -- Dirección para el puerto Rd2
      Rd2        : out std_logic_vector (31 downto 0);  -- Dato del puerto Rd2
      A3         : in  std_logic_vector ( 4 downto 0);  -- Dirección para el puerto Wd3
      Wd3        : in  std_logic_vector (31 downto 0);  -- Dato de entrada Wd3
      We3        : in  std_logic                        -- Habilitación de la escritura de Wd3
   ); 
   end component;


   --Declaración de la unidad de control para instanciarla
   component control_unit
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode     : in   std_logic_vector (5 downto 0); -- Codigo de operacion de la instruccion
      -- Seniales para el PC
      Branch     : out  std_logic;                     -- 1=Ejecutandose instruccion branch
      Jump       : out  std_logic;                     -- 1=Ejecutandose instruccion jump
      -- Seniales relativas a la memoria
      MemToReg   : out  std_logic;                     -- 1=Escribir en registro la salida de la mem.
      MemWrite   : out  std_logic;                     -- 1=Escribir la memoria
      MemRead    : out  std_logic;                     -- 1=Leer la memoria
      -- Seniales para la ALU
      ALUSrc     : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp      : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite   : out  std_logic;                     -- 1=Escribir registro
      RegDst     : out  std_logic                      -- 0=Reg. destino es rt, 1=rd
   );
   end component;

begin

   --------------------------------
   --Port maps de los componentes--
   --------------------------------

   --Port map para la instanciación de ALU
   alu_pm: alu PORT MAP (
      OpA        => OpA_EX,
      OpB        => OpB_EX,
      Result     => Result_EX,
      ZFlag      => ZFlag_EX,
      Control    => Control_EX
   );

   --Port map para la instanciación de ALUcontrol
   alu_control_pm: alu_control PORT MAP (
      AluOp      => AluOp_EX,
      Funct      => IDataIn(5 downto 0),
      AluControl => AluControl_EX
   );

   --Port map para la instanciación de la unidad de control
   control_unit_pm: control_unit PORT MAP (
      OpCode    => OpCode_ID,
      Branch    => Branch_ID,
      Jump      => Jump_ID,
      MemToReg  => MemToReg_ID,
      MemWrite  => MemWrite_ID,
      MemRead   => MemRead_ID,
      AluSrc    => AluSrc_ID,
      AluOp     => AluOp_ID,
      RegWrite  => RegWrite_ID,
      RegDst    => RegDst_ID
   );

    --Port map para la instanciación del banco de registros
   reg_bank_pm: reg_bank PORT MAP (
      Clk       => Clk,
      Reset     => Reset,
      A1        => A1_ID,
      Rd1       => Rd1_ID,
      A2        => A2_ID,
      Rd2       => Rd2_ID,
      A3        => A3_WB,
      Wd3       => Wd3_WB,
      We3       => We3_WB
   );

   -----------
   --Fase IF--
   -----------
   
   --Conexion de la memoria de instrucciones
   IDataIn_IF <= IDataIn;
   IAddr      <= IAddr_IF;

   --Actualización del valor del contador de programa
   PCPlus4_IF <= PC_IF + 4;
   
   --Calculo del siguiente contador de programa
   NextPC_IF <= BranchAddress_MEM when (Branch_MEM = '1') and (ZFlag_MEM = '1') else
                JumpAddr_MEM      when (Jump_MEM = '1')                         else
                PCPlus4_IF;
   
   -- Conexion de la direccion de la instruccion
   IAddr_IF <= PC_IF;



   -----------
   --Fase ID--
   -----------

   --Decodificacion de la instruccion 
   Rt_ID     <= IDataIn(20 downto 16);
   Rd_ID     <= IDataIn(15 downto 11);
   OpCode_ID <= IDataIn_ID(31 downto 26);
   A1_ID     <= IDataIn_ID(25 downto 21);
   A2_ID     <= IDataIn_ID(20 downto 16);

   -- Calculo de la extension de signo para el branch
   ExtensionSigno_ID(31 downto 16) <= (others => IDataIn_ID(15));
   ExtensionSigno_ID(15 downto  0) <= IDataIn_ID(15 downto 0);



   -----------
   --Fase EX--
   -----------

   --Calculo de direccion de branch
   BranchAddress_EX <= (ExtensionSigno_EX(29 downto 0) & "00") + PCPlus4_EX;

   -- Calculo de direccion de salto
   JumpAddr_EX(31 downto 28) <= PCPlus4_EX(31 downto 28);
   JumpAddr_EX(27 downto  2) <= ExtensionSigno_EX(25 downto 0);
   JumpAddr_EX( 1 downto  0) <= "00";

   --Multiplexor de A3
   A3_EX <= Rt_EX when RegDst_EX = '0' else
            Rd_EX;

   -- Campo funct de la instruccion
   Funct_EX <= ExtensionSigno_EX(5 downto 0);

   --Conexion del operando A de la ALU con adelantamiento
   OpA_EX <= Result_MEM when (A1_ID = A3_MEM  and A3_MEM /= "00000") else
             Wd3_WB when (A1_ID = A3_WB and A3_WB /= "00000") else
             Rd1_EX;

   --Multiplexor de OpB
   OpB_EX <= MUX_EX when ALUSrc_EX = '0' else ExtensionSigno_EX;
   MUX_EX <= Result_MEM when (A2_ID = A3_MEM and A3_MEM /= "00000") else
             Wd3_WB when (A2_ID = A3_WB and A3_WB /= "00000") else
             Rd2_EX;

   --Conexion de la senal control a la ALUControl
   Control_EX <= ALUcontrol_EX;



   ------------
   --Fase MEM--
   ------------

   --Conexiones a la memoria de datos
   DDataIn_MEM <= DDataIn;
   DAddr       <= Result_MEM;
   DDataOut    <= Rd2_MEM;
   DWrEn       <= MemWrite_MEM;
   DRdEn       <= MemRead_MEM;



   -----------
   --Fase WB--
   -----------

   --Conexion de WriteEnable
   We3_WB <= RegWrite_WB;

   --Multiplexor de Wd3    
   Wd3_WB <= Result_WB when MemToReg_WB = '0' else DDataIn_WB;


   ------------------
   --Hazarding unit--
   ------------------
   PCWrite   <= '0' when (OpCode_EX = LW_OPCODE and (A2_ID = A3_MEM or A1_ID = A3_MEM)) else '1';
   IFIDWrite <= '0' when (OpCode_EX = LW_OPCODE and (A2_ID = A3_MEM or A1_ID = A3_MEM)) else
                '0' when (Branch_EX = '1' and ZFlag_EX = '1')                            else '1';
   EXMEMStop <= '1' when (OpCode_EX = LW_OPCODE and (A2_ID = A3_MEM or A1_ID = A3_MEM)) else
                '1' when (Branch_EX = '1' and ZFlag_EX = '1')                            else '0';
   IFIDStop  <= '1' when (OpCode_EX = BEQ_OPCODE)                                       else '0';


   --Proceso de reseteo del PC o de incremento del mismo
   procesador: process(Clk,Reset)
   begin
      --Contador de programa
      if Reset = '1' then
         PC_IF <= x"00000000";
      elsif (rising_edge(Clk) and PCWrite = '1') then
	 PC_IF <= NextPC_IF;
      end if;

   end process;
	 
   -------------------
   -- Pipeline IF/ID--
   -------------------
   pipelineIFID: process(Clk, Reset)
      begin
         if Reset = '1' then
            PCPlus4_ID <= x"00000000";
            IDataIn_ID <= x"00000000";
         elsif rising_edge(Clk) then
            PCPlus4_ID <= PCPlus4_IF;
            if IFIDWrite ='1' then
               IDataIn_ID <= IDataIn_IF;
            elsif IFIDStop = '1' then 
               IDataIn_ID <= x"00000000";
            end if;
         end if;
      end process;

   -------------------
   -- Pipeline ID/EX--
   -------------------
   pipelineIDEX: process(Clk, Reset)
      begin
         if Reset = '1' then
            RegWrite_EX       <= '0';
            MemToReg_EX       <= '0';
            Branch_EX         <= '0';
            RegDst_EX         <= '0';
            ALUOp_EX          <= "000";
            ALUSrc_EX         <= '0';
            Jump_EX           <= '0';
            PCPlus4_EX        <= x"00000000";
            Rd1_EX            <= x"00000000";
            Rd2_EX            <= x"00000000";
            ExtensionSigno_EX <= x"00000000";
            Rt_EX             <= "00000";
            Rd_EX             <= "00000";
            MemRead_EX        <= '0';
            MemWrite_EX       <= '0';
            OpCode_EX         <= "000000";
         elsif rising_edge(Clk) then
            RegWrite_EX       <= RegWrite_ID;
            MemToReg_EX       <= MemToReg_ID;
            Branch_EX         <= Branch_ID;
            Jump_EX           <= Jump_ID;
            RegDst_EX         <= RegDst_ID;
            ALUOp_EX          <= ALUOp_ID;
            ALUSrc_EX         <= ALUSrc_ID;
            PCPlus4_EX        <= PCPlus4_ID;
            Rd1_EX            <= Rd1_ID;
            Rd2_EX            <= Rd2_ID;
            ExtensionSigno_EX <= ExtensionSigno_ID;
            Rt_EX             <= Rt_ID;
            Rd_EX             <= Rd_ID;
            MemRead_EX        <= MemRead_ID;
            MemWrite_EX       <= MemWrite_ID;
            OpCode_EX         <= OpCode_ID;
         end if;
      end process;

   --------------------
   -- Pipeline EX/MEM--
   --------------------
   pipelineEXMEM: process(Clk, Reset)
      begin
         if Reset = '1' then
            RegWrite_MEM      <= '0';
            Branch_MEM        <= '0';
            Jump_MEM          <= '0';
            ZFlag_MEM         <= '0';
            Result_MEM        <= x"00000000";
            Rd2_MEM           <= x"00000000";
            A3_MEM            <= "00000";
            MemRead_MEM       <= '0';
            MemWrite_MEM      <= '0';
            BranchAddress_MEM <= x"00000000";
            JumpAddr_MEM      <= x"00000000";
            MemToReg_MEM      <= '0';
         elsif rising_edge(Clk) then
            ZFlag_MEM         <= ZFlag_EX;
            Result_MEM        <= Result_EX;
            Rd2_MEM           <= Rd2_EX;
            A3_MEM            <= A3_EX;
            BranchAddress_MEM <= BranchAddress_EX;
            JumpAddr_MEM      <= JumpAddr_EX;
            
            if EXMEMStop = '0' then 
               RegWrite_MEM      <= RegWrite_EX;
               Branch_MEM        <= Branch_EX;
               Jump_MEM          <= Jump_EX;
               MemRead_MEM       <= MemRead_EX;
               MemWrite_MEM      <= MemWrite_EX;
               MemToReg_MEM      <= MemToReg_EX;
            else
               RegWrite_MEM      <= '0';
               Branch_MEM        <= '0';
               Jump_MEM          <= '0';
               MemRead_MEM       <= '0';
               MemWrite_MEM      <= '0';
               MemToReg_MEM      <= '0';
            end if;
         end if;
      end process;

   --------------------
   -- Pipeline MEM/WB--
   --------------------
   pipelineMEMWB: process(Clk, Reset)
      begin
         if Reset = '1' then
            RegWrite_WB <= '0';
            MemToReg_WB <= '0';
            DDataIn_WB  <= x"00000000";
            Result_WB   <= x"00000000";
            A3_WB       <= "00000";
         elsif rising_edge(Clk) then
            RegWrite_WB <= RegWrite_MEM;
            MemToReg_WB <= MemToReg_MEM;
            DDataIn_WB  <= DDataIn_MEM;
            Result_WB   <= Result_MEM;
            A3_WB       <= A3_MEM;
         end if;
      end process;

   end architecture;
