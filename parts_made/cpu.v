module cpu(
    input wire clk,
    input wire reset
);
// Fios de Controle
    wire PC_w;
    wire PCWrite;
    wire PCWriteCond;
    wire PCSource;
    wire IorD;
    wire MemReadOrWrite;
    wire IRWrite;
    wire RegDst;
    wire RegWrite;
    wire MemToReg;
    wire LoadAMem;
    wire LoadBMem;
    wire AluSrcA;
    wire AluSrcB;
    wire AluOp;
    wire AluOutWrite;
    wire EPCWrite;
    wire BranchOp;
    wire MuxShiftQtd;
    wire MuxShiftInput;
    wire OPLow;
    wire OPhi;
    wire MuxBH;
    wire ExtendOP;
    wire ExceptionAddress;
    wire initDiv;
    wire initMult;
    wire HIWrite;
    wire LOWrite;
    wire Shift;
    wire INTCause;
    wire CauseWrite;

// Fios de Dados

    wire[31:0] PC_in;
    wire[31:0] PC_out;
    wire[31:0] MEM_in;
    wire[31:0] MEM_out;

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_in,
        PC_out
    );

    mux_IorD Mux_IorD_(
        PC_out,
        data_1, //Mudar e declarar fios de entrada no mux
        data_2,
        data_3,
        data_4
    );

    Memoria MEM_(
        clk,
        PC_out,
        MemReadOrWrite,
        MEM_in,
        MEM_out
    );

    
endmodule