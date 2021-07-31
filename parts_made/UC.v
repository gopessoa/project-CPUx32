module UC(

//INPUTS
    //utils
    input wire clk,
    input wire reset,
    //opcode da instrução
    input wire [5:0] Opcode,          //  -->     undefOPcode exception
    input wire [5:0] Funct,
    //flags
    input wire [31:0] Bvalue,   //  -->     divByZero exception if(B == 0)
    input wire overflow,        //  -->     OVERFLOW exception para adição
    //input wire undef opcode 

    //OUTPUTS
    //MUX
    output reg A_w,
    output reg B_w,
    output reg WDMux = 1'b0,
    output reg MemDataRegLoad, //???
    output reg PCWrite,
    output reg PCWriteCond,
    output reg [2:0] PCSource,
    output reg [2:0] IorD,
    output reg MemReadOrWrite, 
    output reg IRWrite,
    output reg [2:0] RegDst,
    output reg RegWrite,
    output reg [3:0] MemToReg,
    output reg LoadAMem,
    output reg LoadBMem,
    output reg AluSrcA,
    output reg [1:0] AluSrcB,
    output reg [2:0] AluOP,
    output reg AluOutWrite,
    output reg EPCWrite,
    output reg [1:0] BranchOp,
    output reg [1:0] MuxShiftQtd,
    output reg [1:0] MuxShiftInput,
    output reg OPlow,
    output reg OPhi, 
    output reg MuxBH,
    output reg ExtendOP,
    output reg [7:0] ExceptionAddress, //???
    output reg initDiv,
    output reg initMult,
    output reg HIWrite, 
    output reg LOWrite,
    output reg [2:0] Shift,

    output reg INTCause, //???
    output reg CauseWrite //???

);

//variáveis
reg [6:0]   ESTADO;
reg [2:0]   CONTADOR;

//CONSTANTES
    //ESTADOS PRINCIPAIS
    parameter RESET           = 7'b0000000; // 0 ok
    parameter FETCH           = 7'b0000001; // 1 ok
    parameter FETCH_2           = 7'b0000010; // 2 ok
    parameter FETCH_3           = 7'b0000011; // 3 ok
    parameter DECODE            = 7'b0000100; // 4  ok
    parameter DECODE_2          = 7'b0000101; // 5 ok
    parameter WAIT              = 7'b0000110; // 6 vai usar isso?
    //ESTADOS DE FORMATO R
    parameter ADD               = 7'b0000111; // 7 ok
    parameter SUB               = 7'b0001000; // 8 ok
    parameter AND               = 7'b0001001; // 9 ok
    parameter ALU_TO_REG        = 7'b0001010; // 10 ok
    parameter MULT_1            = 7'b0001011; // 11 ok
    parameter MULT_2            = 7'b0001100; // 12 ok
    parameter DIV_1             = 7'b0001101; // 13 ok
    parameter DIV_2             = 7'b0001110; // 14 ok
    parameter MFHI              = 7'b0001111; // 15 ok
    parameter MFLO              = 7'b0010000; // 16 ok
    parameter SHIFT_SHAMT       = 7'b0010001; // 17 ok
    parameter SLL               = 7'b0010010; // 18 ok
    parameter SRL               = 7'b0010011; // 19ok
    parameter SRA               = 7'b0010100; // 20 ok
    parameter SHIFT_REG         = 7'b0010101; // 21 ok
    parameter SRAV              = 7'b0010110; // 22 ok
    parameter SLLV              = 7'b0010111; // 23 ok
    parameter STORE_SHIFT       = 7'b0011000; // 24 ok
    parameter JR                = 7'b0011001; // 25 ok
    parameter SLT_1             = 7'b0011010; // 26 ok
    parameter SLT_2             = 7'b0011011; // 27 ok
    parameter BREAK_1           = 7'b0011100; // 28 ok
    parameter BREAK_2           = 7'b0011101; // 29 ok
    parameter RTE               = 7'b0011110; // 30 ok
    parameter ADDM_1            = 7'b0011111; // 31 ok
    parameter ADDM_2            = 7'b0100000; // 32 ok
    parameter ADDM_3            = 7'b0100001; // 33 ok
    parameter ADDM_4            = 7'b0100010; // 34 ok
    parameter ADDM_5            = 7'b0100011; // 35 ok 
    parameter ADDM_6            = 7'b0100100; // 36 ok
    //ESTADOS DO FORMATO J
    parameter J                 = 7'b0100101; // 37 ok
    parameter JAL_1             = 7'b0100110; // 38 ok
    parameter JAL_2             = 7'b0100111; // 39 ok
    parameter JAL_3             = 7'b0101000; // 40 ok
    //ESTADOS DO FORMATO I  
    parameter ADDI_ADDIU        = 7'b0101001; // 41 ok
    parameter ADDI              = 7'b0101010; // 42 ok
    parameter ADDIU             = 7'b0101011; // 43 ok
    parameter BEQ_BNE_BGT_BLE   = 7'b0101100; // 44 ok
    parameter BEQ               = 7'b0101101; // 45 ok
    parameter BNE               = 7'b0101110; // 46 ok
    parameter BGT               = 7'b0101111; // 47 ok
    parameter BLE               = 7'b0110000; // 48 ok
    parameter LB_LH_LW          = 7'b0110001; // 49 ok
    parameter LB                = 7'b0110010; // 50 ok
    parameter LH                = 7'b0110011; // 51 ok
    parameter LW                = 7'b0110100; // 52 ok
    parameter SB_SH_SW          = 7'b0110101; // 53 ok
    parameter SB                = 7'b0110110; // 54 ok
    parameter SH                = 7'b0110111; // 55 ok
    parameter SW                = 7'b0111000; // 56 ok
    parameter LUI               = 7'b0111001; // 57 ok
    parameter SLTI_1            = 7'b0111010; // 58 ok
    parameter SLTI_2            = 7'b0111011; // 59 ok
    parameter SLLM_1            = 7'b0111100; // 60 ok
    parameter SLLM_2            = 7'b0111101; // 61 ok
    parameter SLLM_3            = 7'b0111110; // 62 ok
    //ESTADOS DE EXCEPTIONS
    parameter UNDEF_OP          = 7'b0111111; // 63 O
    parameter OVERFLOW          = 7'b1000000; // 64 OK
    parameter DIV_BY_ZERO       = 7'b1000001; // 65 OK
    parameter LOAD_EXP_TO_PC_1  = 7'b1000010; // 66 OK
    parameter LOAD_EXP_TO_PC_2  = 7'b1000011; // 67 OK
    //LOCK WRITE
    parameter LOCK_WRITE        = 7'b1000100; // 68 ok




      

    //OPCODES E FUNCTS
        //R
    parameter OP_R     =   6'b000000;  //  0x0 = 0
    parameter FUNCT_ADD     =   6'b100000;  //  0x20 = 32 
    parameter FUNCT_AND     =   6'b100100;  //  0x24 = 36
    parameter FUNCT_DIV     =   6'b011010;  //  0x1a = 26
    parameter FUNCT_MULT    =   6'b011000;  //  0x18 = 24
    parameter FUNCT_JR      =   6'b001000;  //  0x8  = 8
    parameter FUNCT_MFHI    =   6'b010000;  //  0x10 = 16
    parameter FUNCT_MFLO    =   6'b010010;  //  0x12 = 18
    parameter FUNCT_SLL     =   6'b000000;  //  0x0  = 0
    parameter FUNCT_SLLV    =   6'b000100;  //  0x4  = 4
    parameter FUNCT_SLT     =   6'b101010;  //  0x2a
    parameter FUNCT_SRA     =   6'b000011;  //  0x3  
    parameter FUNCT_SRAV    =   6'b000111;  //  0x7
    parameter FUNCT_SRL     =   6'b000010;  //  0x2
    parameter FUNCT_SUB     =   6'b100010;  //  0x22
    parameter FUNCT_BREAK   =   6'b001101;  //  0xd
    parameter FUNCT_RTE     =   6'b010011;  //  0x13
    parameter FUNCT_ADDM    =   6'b000101;  //  0x5




        //I
    parameter OP_ADDI          =   6'b001000;  //  0x8  = 8
    parameter OP_ADDIU         =   6'b001001;  //  0x9  = 9
    parameter OP_BEQ           =   6'b000100;  //  0x4  = 4
    parameter OP_BNE           =   6'b000101;  //  0x5  = 5
    parameter OP_BLE           =   6'b000110;  //  0x6  = 6
    parameter OP_BGT           =   6'b000111;  //  0x7  = 7
    parameter OP_SLLM          =   6'b000001;  //  0x1  = 1
    parameter OP_LB            =   6'b100000;  //  0x20 = 32 
    parameter OP_LH            =   6'b100001;  //  0x21 = 33
    parameter OP_LUI           =   6'b001111;  //  0xf  = 15
    parameter OP_LW            =   6'b100011;  //  0x23 = 35
    parameter OP_SB            =   6'b101000;  //  0x28 = 40 
    parameter OP_SH            =   6'b101001;  //  0x29 = 41
    parameter OP_SLTI          =   6'b001010;  //  0xa = 10
    parameter OP_SW            =   6'b101011;  //  0x2b = 43

        //J
    parameter OP_J             =   6'b000010;  //  0x2 = 2
    parameter OP_JAL           =   6'b000011;  //  0x3 = 3

    initial begin
      ESTADO = RESET;
    end

    always @(posedge clk) begin
      if (reset == 1'b1) begin
        //USADOS
        RegDst = 3'b010;
        MemToReg = 4'b1000;
        RegWrite = 1'b1;
        
        //NÃO USADOS
        A_w = 1'b0;
        B_w = 1'b0;
        MemDataRegLoad = 1'b0;
        PCWrite = 1'b0; 
        PCWriteCond = 1'b0;// ?
        MemReadOrWrite = 1'b0;
        IRWrite = 1 'b0;
        AluOutWrite = 1'b0;
        EPCWrite = 1'b0;
        initDiv = 1'b0;// ?
        initMult = 1'b0;// ?
        HIWrite = 1'b0;
        LOWrite = 1'b0;
        CauseWrite = 1'b0;// ?
        WDMux = 1'b0;
        PCSource = 3'b000;
        IorD = 3'b000;
        RegDst = 3'b000;
        RegWrite = 1'b0;
        MemToReg = 4'b0000;
        LoadAMem = 1'b0;
        LoadBMem = 1'b0;
        AluSrcA = 1'b0;
        AluSrcB = 2'b00;
        AluOP = 3'b000;
        BranchOp = 2'b00;
        MuxShiftQtd = 2'b00;
        MuxShiftInput = 2'b00;
        OPlow = 1'b0;
        OPhi = 1'b0; 
        MuxBH = 1'b0;
        ExtendOP = 1'b0;
        ExceptionAddress = 8'b00000000;
         
        
        Shift = 3'b000;
        INTCause = 1'b0; 
        
      end else begin
        case(ESTADO)
          FETCH: begin
            //USADOS
            AluSrcA = 1'b0;
            AluSrcB = 2'b01;
            AluOP = 3'b001;
            AluOutWrite = 1'b1;
            IorD = 3'b000;
            MemReadOrWrite = 1'b1;

            //NÃO USADOS
            A_w = 1'b0;
            B_w = 1'b0;
            MemDataRegLoad = 1'b0;
            PCWrite = 1'b0; 
            PCWriteCond = 1'b0;// ?
            IRWrite = 1 'b0;
            AluOutWrite = 1'b0;
            EPCWrite = 1'b0;
            initDiv = 1'b0;// ?
            initMult = 1'b0;// ?
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            CauseWrite = 1'b0;// ?
            WDMux = 1'b0;
            PCSource = 3'b000;
            IorD = 3'b000;
            RegDst = 3'b000;
            RegWrite = 1'b0;
            MemToReg = 4'b0000;
            LoadAMem = 1'b0;
            LoadBMem = 1'b0;
            AluSrcA = 1'b0;
            AluSrcB = 2'b00;
            AluOP = 3'b000;
            BranchOp = 2'b00;
            MuxShiftQtd = 2'b00;
            MuxShiftInput = 2'b00;
            OPlow = 1'b0;
            OPhi = 1'b0; 
            MuxBH = 1'b0;
            ExtendOP = 1'b0;
            ExceptionAddress = 8'b00000000;
             
            
            Shift = 3'b000;
            INTCause = 1'b0;

            //NEXT STATE
            ESTADO = FETCH_2;
          end
          FETCH_2: begin
            //USADOS
            PCSource = 3'b000;
            PCWrite = 1'b1;

            //NÃO USADOS
            A_w = 1'b0;
            B_w = 1'b0;
            MemDataRegLoad = 1'b0;
            PCWriteCond = 1'b0;// ?
            MemReadOrWrite = 1'b0;
            IRWrite = 1 'b0;
            AluOutWrite = 1'b0;
            EPCWrite = 1'b0;
            initDiv = 1'b0;// ?
            initMult = 1'b0;// ?
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            CauseWrite = 1'b0;// ?
            WDMux = 1'b0;
            IorD = 3'b000;
            RegDst = 3'b000;
            RegWrite = 1'b0;
            MemToReg = 4'b0000;
            LoadAMem = 1'b0;
            LoadBMem = 1'b0;
            AluSrcA = 1'b0;
            AluSrcB = 2'b00;
            AluOP = 3'b000;
            BranchOp = 2'b00;
            MuxShiftQtd = 2'b00;
            MuxShiftInput = 2'b00;
            OPlow = 1'b0;
            OPhi = 1'b0; 
            MuxBH = 1'b0;
            ExtendOP = 1'b0;
            ExceptionAddress = 8'b00000000;
             
            
            Shift = 3'b000;
            INTCause = 1'b0;

            //next stage
            ESTADO = FETCH_3;
          end
          FETCH_3: begin
            //USADOS
            PCWrite = 1'b0;
            MemReadOrWrite = 1'b0;
            IRWrite = 1'b1;

            //NÃO USADOS
            A_w = 1'b0;
            B_w = 1'b0;
            MemDataRegLoad = 1'b0;
            PCWriteCond = 1'b0;// ?
            AluOutWrite = 1'b0;
            EPCWrite = 1'b0;
            initDiv = 1'b0;// ?
            initMult = 1'b0;// ?
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            CauseWrite = 1'b0;// ?
            WDMux = 1'b0;
            PCSource = 3'b000;
            IorD = 3'b000;
            RegDst = 3'b000;
            RegWrite = 1'b0;
            MemToReg = 4'b0000;
            LoadAMem = 1'b0;
            LoadBMem = 1'b0;
            AluSrcA = 1'b0;
            AluSrcB = 2'b00;
            AluOP = 3'b000;
            BranchOp = 2'b00;
            MuxShiftQtd = 2'b00;
            MuxShiftInput = 2'b00;
            OPlow = 1'b0;
            OPhi = 1'b0; 
            MuxBH = 1'b0;
            ExtendOP = 1'b0;
            ExceptionAddress = 8'b00000000;
             
            
            Shift = 3'b000;
            INTCause = 1'b0;

            //next stage
            ESTADO = DECODE;
          end
          DECODE: begin
            //USADOS
            AluSrcA = 1'b0;
            AluSrcB = 2'b10;
            AluOP = 3'b001;
            IRWrite = 1'b0;

            //NÃO USADOS
            A_w = 1'b0;
            B_w = 1'b0;
            MemDataRegLoad = 1'b0;
            PCWrite = 1'b0; 
            PCWriteCond = 1'b0;// ?
            MemReadOrWrite = 1'b0;
            AluOutWrite = 1'b0;
            EPCWrite = 1'b0;
            initDiv = 1'b0;// ?
            initMult = 1'b0;// ?
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            CauseWrite = 1'b0;// ?
            WDMux = 1'b0;
            PCSource = 3'b000;
            IorD = 3'b000;
            RegDst = 3'b000;
            RegWrite = 1'b0;
            MemToReg = 4'b0000;
            LoadAMem = 1'b0;
            LoadBMem = 1'b0;
            BranchOp = 2'b00;
            MuxShiftQtd = 2'b00;
            MuxShiftInput = 2'b00;
            OPlow = 1'b0;
            OPhi = 1'b0; 
            MuxBH = 1'b0;
            ExtendOP = 1'b0;
            ExceptionAddress = 8'b00000000;
             
            
            Shift = 3'b000;
            INTCause = 1'b0;

            //next state
            ESTADO = DECODE_2;
          end
          DECODE_2: begin
            //USADOS
            AluOutWrite = 1'b1;
            RegWrite = 1'b1;
            LoadAMem = 1'b0;
            LoadBMem = 2'b00;
            A_w = 1'b1;
            B_w = 1'b1;

            //NÃO USADOS
            MemDataRegLoad = 1'b0;
            PCWrite = 1'b0; 
            PCWriteCond = 1'b0;// ?
            MemReadOrWrite = 1'b0;
            IRWrite = 1 'b0;
            EPCWrite = 1'b0;
            initDiv = 1'b0;// ?
            initMult = 1'b0;// ?
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            CauseWrite = 1'b0;// ?
            WDMux = 1'b0;
            PCSource = 3'b000;
            IorD = 3'b000;
            RegDst = 3'b000;
            MemToReg = 4'b0000;
            AluSrcA = 1'b0;
            AluSrcB = 2'b00;
            AluOP = 3'b000;
            BranchOp = 2'b00;
            MuxShiftQtd = 2'b00;
            MuxShiftInput = 2'b00;
            OPlow = 1'b0;
            OPhi = 1'b0; 
            MuxBH = 1'b0;
            ExtendOP = 1'b0;
            ExceptionAddress = 8'b00000000;
             
            
            Shift = 3'b000;
            INTCause = 1'b0;

            //next state

            case(Opcode)

              //INTRUÇÕES EM R
              OP_R: begin

                  case(Funct)
                      FUNCT_ADD: begin
                        ESTADO = ADD;
                      end
                      FUNCT_AND: begin
                        ESTADO = AND;
                      end
                      FUNCT_DIV: begin
                        ESTADO = DIV_1;
                      end
                      FUNCT_MULT: begin
                        ESTADO = MULT_1;
                      end
                      FUNCT_JR: begin
                        ESTADO = JR;
                      end
                      FUNCT_MFHI: begin
                        ESTADO = MFHI;
                      end
                      FUNCT_MFLO: begin
                        ESTADO = MFLO;
                      end
                      FUNCT_SLL: begin
                        ESTADO = SHIFT_SHAMT;
                      end
                      FUNCT_SLLV: begin
                        ESTADO = SLLV;
                      end
                      FUNCT_SLT: begin
                        ESTADO = SLT_1;
                      end
                      FUNCT_SRA: begin
                        ESTADO = SHIFT_SHAMT;
                      end
                      FUNCT_SRAV: begin
                        ESTADO = SRAV;
                      end
                      FUNCT_SRL: begin
                        ESTADO = SHIFT_SHAMT;
                      end
                      FUNCT_SUB: begin
                        ESTADO = SUB;
                      end
                      FUNCT_BREAK: begin
                        ESTADO = BREAK_1;
                      end
                      FUNCT_RTE: begin
                        ESTADO = RTE;
                      end
                      FUNCT_ADDM: begin
                        ESTADO = ADDM_1;
                      end
                    endcase
                end
                  //INSTRUÇÕES I
                    OP_ADDI: begin
                        ESTADO = ADDI_ADDIU;
                    end
                    OP_ADDIU: begin
                        ESTADO = ADDI_ADDIU;
                    end
                    OP_BEQ: begin
                        ESTADO = BEQ_BNE_BGT_BLE;
                    end
                    OP_BNE: begin
                      ESTADO = BEQ_BNE_BGT_BLE;
                    end
                    OP_BLE: begin
                      ESTADO = BEQ_BNE_BGT_BLE;
                    end
                    OP_BGT: begin
                      ESTADO =BEQ_BNE_BGT_BLE;
                    end
                    OP_SLLM: begin
                      ESTADO = SLLM_1;
                    end
                    OP_SLTI: begin
                      ESTADO = SLTI_1;
                    end
                    OP_LUI: begin
                      ESTADO = LUI;
                    end
                    OP_SB: begin
                      ESTADO = SB_SH_SW;
                    end
                    OP_SH: begin
                      ESTADO = SB_SH_SW;
                    end
                    OP_SW: begin
                      ESTADO = SB_SH_SW;
                    end
                    OP_LB:begin
                      ESTADO = LB_LH_LW;
                    end
                    OP_LH:begin
                      ESTADO = LB_LH_LW;
                    end
                    OP_LW:begin
                      ESTADO = LB_LH_LW;
                    end
                        //INSTRUÇÕES J
                    OP_J: begin
                        ESTADO = J;
                    end
                    OP_JAL: begin
                        ESTADO = JAL_1;
                    end
                endcase //opcode
            end //decode 2    
              //ESTADOS DAS INSTRUÇÕES R
            ADD: begin
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b001;
              AluOutWrite = 1;
              
              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next stage
              if (OVERFLOW) begin
                ESTADO = OVERFLOW;
              end else begin
                ESTADO = ALU_TO_REG;
              end
            end
            SUB: begin
              //USADOS
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b010;
              AluOutWrite = 1;
                
              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next stage
              if (OVERFLOW) begin
                ESTADO = OVERFLOW;
              end else begin
                ESTADO = ALU_TO_REG;
              end
            end
            AND: begin
              //USADOS
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b011;
              AluOutWrite = 1;
              
              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next stage
              ESTADO = ALU_TO_REG;
            end
            ALU_TO_REG: begin
              //USADOS
              MemToReg = 4'b0101;
              RegWrite = 1'b1;
              RegDst = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //NEXT STATE
              ESTADO = LOCK_WRITE;
            end
            MULT_1: begin
              //USADOS
              initMult = 1'b1; 

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = MULT_2;
            end
            MULT_2: begin
              OPhi = 1'b1;
              OPlow = 1'b1;
              HIWrite = 1'b1;
              LOWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00; 
              MuxBH = 1'b1;
              ExtendOP = 1'b1;
              ExceptionAddress = 8'b00000000;
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            DIV_1: begin
              initDiv = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = DIV_2;
            end
            DIV_2: begin
              OPhi = 1'b0;
              OPlow = 1'b0;
              HIWrite = 1'b1;
              LOWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              if (Bvalue == 32'b00000000000000000000000000000000) begin
                ESTADO = DIV_BY_ZERO;
              end else begin
                ESTADO = LOCK_WRITE;
              end
            end
            MFHI: begin
              MemToReg = 4'b0110;
              RegDst = 1'b1;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            MFLO: begin
              MemToReg = 4'b0111;
              RegDst = 1'b1;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = LOCK_WRITE;
            end
             SHIFT_SHAMT: begin
               MuxShiftInput = 2'b00;
               MuxShiftQtd = 2'b01;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              if (Funct == FUNCT_SLL) begin
                  ESTADO = SLL;
              end
              if (Funct == FUNCT_SRL) begin
                  ESTADO = SRL;
              end
              if (Funct == FUNCT_SRA) begin
                  ESTADO = SRA;
              end
            end

            SLL: begin
              Shift = 3'b010;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0;

              //NEXT STATE
              ESTADO = STORE_SHIFT;
            end
            SRL: begin
              Shift = 3'b100;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0; 

              //NEXT STATE
              ESTADO = STORE_SHIFT;
            end
            SRA: begin
              Shift = 3'b011;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0; 

              //NEXT STATE
              ESTADO = STORE_SHIFT;
            end
            SHIFT_REG: begin
              MuxShiftInput = 2'b01;
              MuxShiftQtd = 2'b10;
              Shift = 3'b001;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0; 

              //next state
              if (Funct == FUNCT_SLLV) begin
                  ESTADO = SLLV;
              end
              if (Funct == FUNCT_SRAV) begin
                  ESTADO = SRAV;
              end
            end
            SRAV: begin
              Shift = 3'b100;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0; 

              //next state
              ESTADO = STORE_SHIFT;
            end
            SLLV: begin
              Shift = 3'b010;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0; 

              //next state
              ESTADO = STORE_SHIFT;
            end
            STORE_SHIFT: begin
              MemToReg = 4'b0011;
              RegWrite = 1'b1;
              RegDst = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = LOCK_WRITE;
            end
            JR: begin
              AluSrcA = 1'b1;
              AluOP = 3'b000;
              PCSource = 3'b000;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = LOCK_WRITE;
            end
            SLT_1: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b0;
              AluOP = 3'b111;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = SLT_2;
            end
            SLT_2: begin
              MemToReg = 4'b0100;
              RegWrite = 1'b1;
              RegDst = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //NEXT STATE
              ESTADO = LOCK_WRITE;
            end
            BREAK_1: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b1;
              AluOP = 3'b010;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = BREAK_2;
            end
            BREAK_2: begin
              PCSource = 3'b000;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0; 

              //next state
              ESTADO = LOCK_WRITE;
            end
            RTE: begin
              PCSource = 3'b100;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            ADDM_1: begin
              IorD = 3'b100;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = ADDM_2;
            end
            ADDM_2: begin
              LoadAMem = 1'b1;
              A_w = 1'b1;

              //NÃO USADOS
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadBMem = 1'b1;
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = ADDM_2;
            end
            ADDM_3: begin
              IorD = 3'b010;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = ADDM_4;
            end
            ADDM_4: begin
              LoadBMem = 1'b1;
              B_w = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

                //next state
              ESTADO = ADDM_5;
            end
            ADDM_5: begin
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b001;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = ADDM_6;
            end
            ADDM_6: begin
              AluOutWrite = 1'b1;
              MemToReg = 3'b101;
              RegDst = 1'b1;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
              
            //ESTADOS INSTRUÇÕES I
            ADDI_ADDIU: begin
              ExtendOP = 1'b1;
              AluSrcB = 2'b11;
              AluSrcA = 1'b1;
              AluOP = 3'b001;
              AluOutWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              if(Opcode == OP_ADDI) begin
                ESTADO = ADDI;
              end 
              else begin
                ESTADO = ADDIU;
              end
            end
            ADDI: begin
              MemToReg = 4'b0101;
              RegDst = 2'b00;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              if (OVERFLOW) begin
                ESTADO = OVERFLOW;
              end else begin
                ESTADO = LOCK_WRITE;
              end
            end
            ADDIU: begin
              MemToReg = 4'b0101;
              RegDst = 2'b00;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            BEQ_BNE_BGT_BLE: begin
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b111;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;
              //next state
              if(Opcode == OP_BEQ) begin
                ESTADO = BEQ;
              end
              if(Opcode == OP_BNE) begin
                ESTADO = BNE;
              end
              if(Opcode == OP_BLE) begin
                ESTADO = BLE;
              end
              if(Opcode == OP_BGT) begin
                ESTADO = BGT;
              end
            end
            BEQ: begin
              BranchOp = 2'b00;
              PCSource = 3'b101;
              PCWriteCond = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            BNE: begin
              BranchOp = 2'b01;
              PCSource = 3'b101;
              PCWriteCond = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            BGT: begin
              BranchOp = 2'b10;
              PCSource = 3'b101;
              PCWriteCond = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            BLE: begin
              BranchOp = 2'b11;
              PCSource = 3'b101;
              PCWriteCond = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            LB_LH_LW: begin
              AluSrcA = 1'b1;
              AluSrcB = 2'b10;
              ExtendOP = 1'b1;
              AluOP = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

                //next state
              if(Opcode == OP_LW) begin
                ESTADO = LW;
              end
              if(Opcode == OP_LH) begin
                ESTADO = LH;
              end
              if(Opcode == OP_LB) begin
                ESTADO = LB;
              end
            end
            LW: begin
              AluOutWrite = 1'b1;
              IorD = 1'b1;
              MemReadOrWrite = 1'b1;
              RegDst = 1'b0;
              ExtendOP = 1'b0;
              MemToReg = 4'b0000;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            LH: begin
              AluOutWrite = 1'b1;
              IorD = 1'b1;
              MemReadOrWrite = 1'b1;
              RegDst = 1'b0;
              ExtendOP = 1'b0;
              MemToReg = 4'b0001;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            LB: begin
              AluOutWrite = 1'b1;
              IorD = 1'b1;
              MemReadOrWrite = 1'b1;
              RegDst = 1'b0;
              MemToReg = 4'b0010;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            SB_SH_SW: begin
              LoadAMem = 1'b0;
              AluSrcA = 1'b1;
              AluSrcB = 2'b01;
              AluOP = 3'b001;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadBMem = 1'b1;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              if(Opcode == OP_SW) begin
                ESTADO = SW;
              end
              if(Opcode == OP_SH) begin
                ESTADO = SH;
              end
              if(Opcode == OP_SB) begin
                ESTADO = SB;
              end
            end
            SW: begin
              AluOutWrite = 1'b1;
              LoadBMem = 1'b0;
              IorD = 1'b1;
              WDMux = 1'b1;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            SH: begin
              AluOutWrite = 1'b1;
              LoadBMem = 1'b0;
              IorD = 1'b1;
              WDMux = 1'b0;
              MuxBH = 1'b0;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            SB: begin
              AluOutWrite = 1'b1;
              LoadBMem = 1'b0;
              IorD = 1'b1;
              WDMux = 1'b0;
              MuxBH = 1'b1;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            LUI: begin
              MemToReg = 2'b11;
              MuxShiftInput = 2'b10;
              MuxShiftQtd = 2'b11;
              RegDst = 2'b00;
              Shift = 3'b010;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            SLTI_1: begin
              AluSrcA = 1'b1;
              AluSrcB = 2'b11;
              ExtendOP = 1'b1;
              AluOP = 3'b111;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //NEXT STATE
              ESTADO = SLTI_2;
            end
            SLTI_2: begin
              MemToReg = 4'b0100;
              RegDst = 2'b00;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end
            SLLM_1: begin
              LoadAMem = 1'b0;
              ExtendOP = 1'b0;
              AluSrcA = 1'b1;
              AluSrcB = 2'b11;
              AluOP = 3'b001;
              AluOutWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadBMem = 1'b1;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = SLLM_2;
            end
            SLLM_2: begin
              PCSource = 3'b001;
              PCWrite = 1'b1;
              IorD = 1'b0;
              MemReadOrWrite = 1'b1;
              MuxShiftInput = 2'b00;
              MuxShiftQtd = 2'b00;
              LoadBMem = 1'b0;
              Shift = 3'b010;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              INTCause = 1'b0;

              //next state
              ESTADO = SLLM_3;
            end
            SLLM_3: begin
              MemToReg = 4'b0011;
              RegDst = 2'b00;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE;
            end

            //ESTADOS INSTRUÇÕES J
            J: begin
              PCSource = 3'b010;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOCK_WRITE; 
            end
            JAL_1: begin
              AluSrcA = 1'b1;
              AluOP = 3'b000;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = JAL_2;
            end
            JAL_2: begin
              AluOutWrite = 1'b1;
              MemToReg = 4'b0101;
              RegDst = 2'b11;
              RegWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = JAL_3;
            end
            JAL_3: begin
              PCSource = 3'b010;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

                //next state
              ESTADO = LOCK_WRITE;
            end
            LOCK_WRITE: begin
              A_w = 1'b0;
              B_w = 1'b0;
              WDMux = 1'b0;
              MemDataRegLoad = 1'b0; //
              PCWrite = 1'b0;
              PCWriteCond = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              MemReadOrWrite = 1'b0;
              IRWrite = 1'b0;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000; 
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcA = 1'b0; 
              AluSrcB = 2'b00; 
              AluOP = 3'b000;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0;
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 1'b0;
              initDiv = 1'b0;
              initMult = 1'b0;
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              Shift = 3'b000;
              INTCause = 1'b0; //???
              CauseWrite = 1'b0;//???

              //next state
              ESTADO = FETCH;
            end
            UNDEF_OP: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b1;
              AluOP = 3'b010;
              EPCWrite = 1'b1;
              ExceptionAddress = 8'b11111101;
              IorD = 3'b011;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOAD_EXP_TO_PC_1;
            end
            OVERFLOW: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b1;
              AluOP = 3'b010;
              EPCWrite = 1'b1;
              ExceptionAddress = 8'b11111110;
              IorD = 3'b011;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOAD_EXP_TO_PC_1;
            end
            DIV_BY_ZERO: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b1;
              AluOP = 3'b010;
              EPCWrite = 1'b1;
              ExceptionAddress = 8'b11111111;
              IorD = 3'b011;
              MemReadOrWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b0;
              LoadBMem = 1'b0;
              AluSrcB = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOAD_EXP_TO_PC_1;
            end
            LOAD_EXP_TO_PC_1: begin
              LoadAMem = 1'b1;
              A_w = 1'b1;

              //NÃO USADOS
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWrite = 1'b0; 
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              PCSource = 3'b000;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadBMem = 1'b1;
              AluSrcA = 1'b1;
              AluSrcB = 2'b00;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = LOAD_EXP_TO_PC_2;
            end
            LOAD_EXP_TO_PC_2: begin
              AluSrcA = 1'b0;
              AluSrcB = 1'b1;
              PCSource = 3'b000;
              PCWrite = 1'b1;

              //NÃO USADOS
              A_w = 1'b0;
              B_w = 1'b0;
              MemDataRegLoad = 1'b0;
              PCWriteCond = 1'b0;// ?
              MemReadOrWrite = 1'b0;
              IRWrite = 1 'b0;
              AluOutWrite = 1'b0;
              EPCWrite = 1'b0;
              initDiv = 1'b0;// ?
              initMult = 1'b0;// ?
              HIWrite = 1'b0;
              LOWrite = 1'b0;
              CauseWrite = 1'b0;// ?
              WDMux = 1'b0;
              IorD = 3'b000;
              RegDst = 3'b000;
              RegWrite = 1'b0;
              MemToReg = 4'b0000;
              LoadAMem = 1'b1;
              LoadBMem = 1'b1;
              AluOP = 3'b000;
              BranchOp = 2'b00;
              MuxShiftQtd = 2'b00;
              MuxShiftInput = 2'b00;
              OPlow = 1'b0;
              OPhi = 1'b0; 
              MuxBH = 1'b0;
              ExtendOP = 1'b0;
              ExceptionAddress = 8'b00000000;
               
              
              Shift = 3'b000;
              INTCause = 1'b0;

              //next state
              ESTADO = FETCH;
            end
        endcase // ESTADO
      end //else
    end // wlways
endmodule