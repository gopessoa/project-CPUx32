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
    output wire PCWrite,
    output wire PCWriteCond,
    output wire PCSource,
    output wire IorD,
    output wire MemRead,
    output wire MemWrite,
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
    parameter E_COMUM  =   2'b00;

    //OPCODES E FUNCTS
        //R
    parameter FORMATO_R     =   6'b000000;  //  0x0 = 0
    parameter FUNCT_ADD     =   6'b100000;  //  0x20 = 32 
  
        //I
    parameter ADDI          =   6'b001000;  //  0x8  = 8
    parameter ADDIU         =   6'b001001;  //  0x9  = 9
    parameter BEQ           =   6'b000100;  //  0x4  = 4
    parameter BNE           =   6'b000101;  //  0x5  = 5
    parameter BLE           =   6'b000110;  //  0x6  = 6
    parameter BGT           =   6'b000111;  //  0x7  = 7
    parameter SLLM          =   6'b000001;  //  0x1  = 1
    parameter LB            =   6'b100000;  //  0x20 = 32 
    parameter LH            =   6'b100001;  //  0x21 = 33
    parameter LUI           =   6'b001111;  //  0xf  = 15
    parameter LW            =   6'b100011;  //  0x23 = 35
    parameter SB            =   6'b101000;  //  0x28 = 40 
    parameter SH            =   6'b101001;  //  0x29 = 41
    parameter SLTI          =   6'b001010;  //  0xa = 10
    parameter SW            =   6'b101011;  //  0x2b = 43

        //J
    parameter J             =   6'b000010;  //  0x2 = 2
    parameter JAL           =   6'b000011;  //  0x3 = 3

endmodule