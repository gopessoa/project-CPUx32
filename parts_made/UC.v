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
    input wire overflow,        //  -->     overflow exception para adição
    //input wire undef opcode 

    //OUTPUTS
    //MUX
    output reg A_w;
    output reg B_w;
    output reg WDMux;
    output reg MemDataRegLoad; //???
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
    output reg [2:0] AluOp,
    output reg AluOutWrite,
    output reg EPCWrite,
    output reg [2:0 ] BranchOp,
    output reg [2:0] MuxShiftQtd,
    output reg [2:0] MuxShiftInput,
    output reg OPLow,
    output reg OPhi, 
    output reg MuxBH,
    output reg ExtendOP,
    output wire ExceptionAddress, //???
    output reg initDiv,
    output reg initMult,
    output reg HIWrite, 
    output reg LOWrite,
    output reg [2:0] Shift,

    output wire INTCause, //???
    output wire CauseWrite //???

);

//variáveis
reg [6:0]   ESTADO;
reg [2:0]   CONTADOR;

//CONSTANTES
    //ESTADOS PRINCIPAIS
    parameter RESET           = 7'b0000000; // 0
    parameter FETCH           = 7'b0000001; // 1
    parameter FETCH_2           = 7'b0000010; // 2
    parameter FETCH_3           = 7'b0000011; // 3
    parameter DECODE            = 7'b0000100; // 4 
    parameter DECODE_2          = 7'b0000101; // 5
    parameter WAIT              = 7'b0000110; // 6
    //ESTADOS DE FORMATO R
    parameter ADD               = 7'b0000111; // 7
    parameter SUB               = 7'b0001000; // 8
    parameter AND               = 7'b0001001; // 9
    parameter ALU_TO_REG        = 7'b0001010; // 10
    parameter MULT_1            = 7'b0001011; // 11
    parameter MULT_2            = 7'b0001100; // 12
    parameter DIV_1             = 7'b0001101; // 13
    parameter DIV_2             = 7'b0001110; // 14
    parameter MFHI              = 7'b0001111; // 15
    parameter MFLO              = 7'b0010000; // 16
    parameter SHIFT_SHAMT       = 7'b0010001; // 17
    parameter SLL               = 7'b0010010; // 18
    parameter SRL               = 7'b0010011; // 19
    parameter SRA               = 7'b0010100; // 20
    parameter SHIFT_REG         = 7'b0010101; // 21
    parameter SRAV              = 7'b0010110; // 22
    parameter SLLV              = 7'b0010111; // 23
    parameter STORE_SHIFT       = 7'b0011000; // 24
    parameter JR                = 7'b0011001; // 25
    parameter SLT_1             = 7'b0011010; // 26
    parameter SLT_2             = 7'b0011011; // 27
    parameter BREAK_1           = 7'b0011100; // 28
    parameter BREAK_2           = 7'b0011101; // 29
    parameter RTE               = 7'b0011110; // 30
    parameter ADDM_1            = 7'b0011111; // 31
    parameter ADDM_2            = 7'b0100000; // 32
    parameter ADDM_3            = 7'b0100001; // 33
    parameter ADDM_4            = 7'b0100010; // 34
    parameter ADDM_5            = 7'b0100011; // 35
    parameter ADDM_6            = 7'b0100100; // 36
    //ESTADOS DO FORMATO J
    parameter J                 = 7'b0100101; // 37
    parameter JAL_1             = 7'b0100110; // 38
    parameter JAL_2             = 7'b0100111; // 39
    parameter JAL_3             = 7'b0101000; // 40
    //ESTADOS DO FORMATO I
    parameter ADDI_ADDIU        = 7'b0101001; // 41
    parameter ADDI              = 7'b0101010; // 42
    parameter ADDIU             = 7'b0101011; // 43
    parameter BEQ_BNE_BGT_BLE   = 7'b0101100; // 44
    parameter BEQ               = 7'b0101101; // 45
    parameter BNE               = 7'b0101110; // 46
    parameter BGT               = 7'b0101111; // 47
    parameter BLE               = 7'b0110000; // 48
    parameter LB_LH_LW          = 7'b0110001; // 49
    parameter LB                = 7'b0110010; // 50
    parameter LH                = 7'b0110011; // 51
    parameter LW                = 7'b0110100; // 52
    parameter SB_SH_SW          = 7'b0110101; // 53
    parameter SB                = 7'b0110110; // 54
    parameter SH                = 7'b0110111; // 55
    parameter SW                = 7'b0111000; // 56
    parameter LUI               = 7'b0111001; // 57
    parameter SLTI_1            = 7'b0111010; // 58
    parameter SLTI_2            = 7'b0111011; // 59
    parameter SLLM_1            = 7'b0111100; // 60
    parameter SLLM_2            = 7'b0111101; // 61
    parameter SLLM_3            = 7'b0111110; // 62
    //ESTADOS DE EXCEPTIONS
    parameter UNDEF_OP          = 7'b0111111; // 63
    parameter OVERFLOW          = 7'b1000000; // 64
    parameter DIV_BY_ZERO       = 7'b1000001; // 65
    parameter LOAD_EXP_TO_PC_1  = 7'b1000010; // 66
    parameter LOAD_EXP_TO_PC_1  = 7'b1000011; // 67
    //LOCK WRITE
    parameter LOCK_WRITE        = 7'b1000100; // 68




      

    //OPCODES E FUNCTS
        //R
    parameter OP_R     =   6'b000000;  //  0x0 = 0
    parameter FUNCT_ADD     =   6'b100000;  //  0x20 = 32 
    parameter FUNCT_AND     =   6'b100100;  //  0x24 = 36
    parameter FUNCT_DIV     =   6'b011010;  //  0x1a = 26
    parameter FUNCT_MULT    =   6'b011000;  //  0x18 = 24
    parameter FUNCT_JR      =   6'0001000;  //  0x8  = 8
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
      ESTADO = RESET
    end

    always @(posedge clk) begin
      if (reset == 1'b1) begin
        RegDst = 3'b010;
        MemToReg = 4'b1000;
        RegWrite = 1'b1;

        A_w = 1'b0;
        B_w = 1'b0;
        HIWrite = 1'b0;
        LOWrite = 1'b0;
        PCWrite = 1'b0;
        MemReadOrWrite = 1'b0;
        IRWrite = 1'b0;
        BranchOp = 3'b000;
      end else begin
        case(ESTADO)
        FETCH: begin
          AluSrcA = 1'b0;
          AluSrcB = 2'b01;
          AluOP = 3'b001;
          AluOutWrite = 1'b1;
          IorD = 3'b000;

          //resto

          //NEXT STATE
          ESTADO = FETCH_2;
        end
        FETCH_2: begin
           PCSource = 3'b000;
           PCWrite = 1'b1;

           //resto

           //next stage
           ESTADO = FETCH_3;
        end
        FETCH_3: begin
           PCWrite = 1'b0;
           MemReadOrWrite = 1'b0;

            //resto

            //next stage
            ESTADO = DECODE;
        end
        DECODE: begin
          AluSrcA = 1'b0;
          AluSrcB = 2'b10;
          AluOP = 3'b001;
          IRWrite = 1'b0;

          //resto

          //next state
          ESTADO = DECODE_2;
        end
        DECODE_2: begin
          AluOutWrite = 1'b1;
          RegWrite = 1'b1;
          LoadAMem = 1'b0;
          LoadBMem = 2'b00;
          A_w = 1'b1;
          B_w = 1'b1;

          //resto

          //next state
           case(Opcode) begin
            //INTRUÇÕES EM R
            OP_R: begin
            case(Funct) begin
                FUNCT_ADD: begin
                  ESTADO = ADD;
                end
                FUNCT_AND: begin
                  ESTADO = AND;
                end
                FUNCT_DIV: begin
                  ESTADO = ALU_TO_REG;
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
                  ESTADO = SLL;
                end
                FUNCT_SLLV: begin
                  ESTADO = SLLV;
                end
                FUNCT_SLT: begin
                  ESTADO = SLT;
                end
                FUNCT_SRA: begin
                  ESTADO = SRA;
                end
                FUNCT_SRAV: begin
                  ESTADO = SRAV;
                end
                FUNCT_SRL: begin
                  ESTADO = SRL;
                end
                FUNCT_SUB: begin
                  ESTADO = SUB;
                end
                FUNCT_BREAK: begin
                  ESTADO = BREAK;
                end
                FUNCT_RTE: begin
                  ESTADO = RTE;
                end
                FUNCT_ADDM: begin
                  ESTADO = ADDM_1;
                end
            endcase
            //INSTRUÇÕES I
            OP_ADDI: begin
              ESTADO = ADDI_ADDIU;
            end
            OP_ADDIU: begin
              ESTADO = ADDI_ADDIU;
            end
            OP_BEQ: begin
              ESTADO: BEQ_BNE_BGT_BLE;
            end
            OP_BNE: begin
              ESTADO: BEQ_BNE_BGT_BLE;
            end
            OP_BLE: begin
              ESTADO: BEQ_BNE_BGT_BLE;
            end
            OP_BGT: begin
              ESTADO: BEQ_BNE_BGT_BLE;
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
              ESTADO = J
            end
            OP_JAL: begin
              ESTADO = JAL_1;
            end    
           endcase
        end
        ADD: begin
          AluSrcA = 1'b1;
          AluSrcB = 2'b00;
          AluOP = 3'b001;
          AluOutWrite = 1;
          
          //resto

          //next stage
          if (overflow) begin
            ESTADO = OVERFLOW;
          end else begin
             ESTADO = ALU_TO_REG;
          end
        end
        SUB: begin
          AluSrcA = 1'b1;
          AluSrcB = 2'b00;
          AluOP = 3'b010;
          AluOutWrite = 1;
          
          //resto

          //next stage
           if (overflow) begin
            ESTADO = OVERFLOW;
          end else begin
             ESTADO = ALU_TO_REG;
          end
        end
        AND: begin
          AluSrcA = 1'b1;
          AluSrcB = 2'b00;
          AluOP = 3'b011;
          AluOutWrite = 1;
          
          //resto

          //next stage
          ESTADO = ALU_TO_REG;
        end
        ALU_TO_REG: begin
          MemToReg = 4'b0101;
          RegWrite = 1'b1;
          RegDst = 1'b1;

          //resto

          //NEXT STATE
          ESTADO = LOCK_WRITE;
        end
        MULT_1: begin
          initMult = 1'b1; 

          //resto 

          //next state
          ESTADO
        end
    end
endmodule