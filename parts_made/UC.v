module UC(

//INPUTS
    //utils
    input wire clk,
    input wire reset,
    //opcode da instrução
    input wire Opcode,          //  -->     undefOPcode exception
    //flags
    input wire [31:0] Bvalue,   //  -->     divByZero exception if(B == 0)
    input wire overflow,        //  -->     overflow exception para adição
    input wire overflow2,       //  -->     pverflow exception para multiplicação

//OUTPUTS
    output wire A_w;
    output wire B_w;
    output wire WDMux;
    output wire MemDataRegLoad;
    output wire PCWrite,
    output wire PCWriteCond,
    output wire PCSource,
    output wire IorD,
    output wire MemReadOrWrite,
    output wire IRWrite,
    output wire RegDst,
    output wire RegWrite,
    output wire MemToReg,
    output wire LoadAMem,
    output wire LoadBMem,
    output wire AluSrcA,
    output wire AluSrcB,
    output wire AluOp,
    output wire AluOutWrite,
    output wire EPCWrite,
    output wire BranchOp,
    output wire MuxShiftQtd,
    output wire MuxShiftInput,
    output wire OPLow,
    output wire OPhi,
    output wire MuxBH,
    output wire ExtendOP,
    output wire ExceptionAddress,
    output wire initDiv,
    output wire initMult,
    output wire HIWrite,
    output wire LOWrite,
    output wire Shift,

    output wire INTCause,
    output wire CauseWrite
);

//variáveis
reg [1:0]   ESTADO;
reg [2:0]   CONTADOR;

//CONSTANTES
    //ESTADOS PRINCIPAIS
    parameter E_RESET           = 0;
    parameter E_FETCH           = 1;
    parameter FETCH_2           = 2;
    parameter FETCH_3           = 3;
    parameter DECODE            = 4;
    parameter DECODE_2          = 5;
    parameter WAIT              = 6;
    //ESTADOS DE FORMATO R
    parameter ADD               = 7;
    parameter SUB               = 8;
    parameter AND               = 9;
    parameter ALU_TO_REG        = 10;
    parameter MULT_1            = 11;
    parameter MULT_2            = 12;
    parameter DIV_1             = 13;
    parameter DIV_2             = 14;
    parameter MFHI              = 15;
    parameter MFLO              = 16; 
    parameter SHIFT_SHAMT       = 17;
    parameter SLL               = 18;
    parameter SRL               = 19;
    parameter SRA               = 20;
    parameter SHIFT_REG         = 21;
    parameter SRAV              = 22;
    parameter SLLV              = 23;
    parameter STORE_SHIFT       = 24;
    parameter JR                = 25;
    parameter SLT_1             = 26;
    parameter SLT_2             = 27;
    parameter BREAK_1           = 28;
    parameter BREAK_2           = 29;
    parameter RTE               = 30;
    parameter ADDM_1            = 31;
    parameter ADDM_2            = 32;
    parameter ADDM_3            = 33;
    parameter ADDM_4            = 34;
    parameter ADDM_5            = 35;
    parameter ADDM_6            = 36;
    //ESTADOS DO FORMATO J
    parameter J                 = 37;
    parameter JAL_1             = 38;
    parameter JAL_2             = 39;
    parameter JAL_3             = 40;
    //ESTADOS DO FORMATO I
    parameter ADDI_ADDIU        = 41;
    parameter ADDI              = 42;
    parameter ADDIU             = 43;
    parameter BEQ_BNE_BGT_BLE   = 44;
    parameter BEQ               = 45;
    parameter BNE               = 46;
    parameter BGT               = 47;
    parameter BLE               = 48;
    parameter LB_LH_LW          = 49;
    parameter LB                = 50;
    parameter LH                = 51;
    parameter LW                = 52;
    parameter SB_SH_SW          = 53;
    parameter SB                = 54;
    parameter SH                = 55;
    parameter SW                = 56;
    parameter LUI               = 57;
    parameter SLTI_1            = 58;
    parameter SLTI_2            = 59;
    parameter SLLM_1            = 60;
    parameter SLLM_2            = 61;
    parameter SLLM_3            = 62;
    //ESTADOS DE EXCEPTIONS
    parameter UNDEF_OP          = 63;
    parameter OVERFLOW          = 64;
    parameter DIV_BY_ZERO       = 65;
    parameter LOAD_EXP_TO_PC_1  = 66;
    parameter LOAD_EXP_TO_PC_1  = 67;
    //LOCK WRITE
    parameter LOCK_WRITE        = 68;




      

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

endmodule