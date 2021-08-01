module cpu(
    input wire clk,
    input wire reset
);
    // Fios de Controle
    wire A_w;
    wire B_w;
    wire WDMux;
    wire MemDataRegLoad; //???
    wire PCWrite;
    wire PCWriteCond;
    wire [2:0] PCSource;
    wire [2:0] IorD;
    wire MemReadOrWrite; 
    wire IRWrite;
    wire [1:0] RegDst;
    wire RegWrite;
    wire [3:0] MemToReg;
    wire LoadAMem;
    wire LoadBMem;
    wire AluSrcA;
    wire [1:0] AluSrcB;
    wire [2:0] AluOP;
    wire AluOutWrite;
    wire EPCWrite;
    wire [1:0] BranchOp;
    wire [1:0] MuxShiftQtd;
    wire [1:0] MuxShiftInput;
    wire OPlow;
    wire OPhi; 
    wire MuxBH;
    wire ExtendOP;
    wire [31:0] ExceptionAddress; //???
    wire HIWrite; 
    wire LOWrite;
    wire [2:0] Shift;
    wire INTCause; //???
    wire CauseWrite; //???

    // Fios de Dados 

    wire [31:0] PC_in;
    wire [31:0] PC_out;
    wire [31:0] MEM_in;
    wire [31:0] MEM_out;
    wire [31:0] WriteData;
    wire [31:0] ReadData1;
	wire [31:0] ReadData2;
    wire [31:0] DataRegA;
    wire [31:0] DataRegB;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] Data_In_Ula_A;
    wire [31:0] Data_In_Ula_B;
    wire [31:0] Result_ULA;
    wire [31:0] AluOut_Out;
    wire [31:0] EPC_Out;
    wire [31:0] Menor_Ula_Extend;
    wire [31:0] Brancher_Out;
    wire [31:0] Sign_extend_out1;
    wire [31:0] Sign_extend_out2;
    wire [31:0] Sign_extend_out3;
    wire [31:0] Sign_extend_out4;
    wire [31:0] Mux_BH_Out;
    wire [31:0] RegShift_Entrada;
    wire [31:0] RegDesloc_Out;
    wire [31:0] Shift_Left2_32_Out;
    wire [31:0] Concat_32_out;
    wire [31:0] Mult_hi_out;
    wire [31:0] Mult_low_out;
    wire [31:0] Div_hi_out;
    wire [31:0] Div_low_out;
    wire [31:0] mux_hi_out;
    wire [31:0] mux_low_out;
    wire [31:0] Reg_Hi_Out;
    wire [31:0] Reg_Low_Out;
    wire [31:0] Cause_out;
    wire [31:0] Reg_Cause_out;
    wire [31:0] IorD_out;
    wire [31:0] Wd_mux_out;
    wire [4:0] RegShift_N;
    wire [27:0] Shift_Left2_26_Out;

    wire [25:0] Concat_25b_out;
    
    wire [15:0] Instr15_0; //Funct na instr R
    wire [31:0] MEM_Data_Reg_Out;
    wire [15:0] Mux_ExtendOp_Out;

    wire [5:0] Instr31_26; //Opcode
    wire [4:0] WriteReg;

    wire [4:0] Instr25_21; 
	wire [4:0] Instr20_16;

    wire Overflow_ULA;
	wire Negativo_ULA;
    wire Zero_ULA;
    wire Igual_ULA;
    wire Maior_ULA;
	wire Menor_ULA;
    wire PC_w;
    
    UC UC_(
        clk,
        reset,
        Instr31_26,
        Instr15_0[5:0],
        B_out,
        Overflow_ULA,

        //outputs
        A_w,
        B_w,
        WDMux,
        MemDataRegLoad, //???
        PCWrite,
        PCWriteCond,
        PCSource,
        IorD,
        MemReadOrWrite, 
        IRWrite,
        RegDst,
        RegWrite,
        MemToReg,
        LoadAMem,
        LoadBMem,
        AluSrcA,
        AluSrcB,
        AluOP,
        AluOutWrite,
        EPCWrite,
        BranchOp,
        MuxShiftQtd,
        MuxShiftInput,
        OPlow,
        OPhi, 
        MuxBH,
        ExtendOP,
        ExceptionAddress, //???
        HIWrite, 
        LOWrite,
        Shift,
        INTCause, //???
        CauseWrite //???
    );

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_in,
        PC_out
    );

    mux_IorD MUX_IORD_(
        IorD,
        PC_out,      
        AluOut_Out,
        B_out,
        ExceptionAddress,
        A_out,
        IorD_out
    );

    Memoria MEM_(
        IorD_out,
        clk,
        MemReadOrWrite,
        Wd_mux_out,
        MEM_out
    );

    Registrador MEM_DATA_REG_(
        clk,
		reset,
		MemDataRegLoad,
		MEM_out,
		MEM_Data_Reg_Out
    );

    Instr_Reg INSTR_REG_(
        clk,
        reset,
        IRWrite,
        MEM_out,
        Instr31_26,
		Instr25_21,
		Instr20_16,
		Instr15_0
    );

    mux_RegDST MUX_REGDST_(
        RegDst,
        Instr20_16,
        Instr15_0[15:11], 
        WriteReg
    );


    Banco_reg BANCO_REG_(
        clk,
        reset,
		RegWrite,
        Instr25_21,
        Instr20_16,
		WriteReg, 
		WriteData,
		ReadData1,
		ReadData2
    );

    mux_LoadAMem MUX_LOADAMEM_(
        LoadAMem,
        ReadData1,
        MEM_Data_Reg_Out,
        DataRegA
    );

    mux_LoadBMem MUX_LOADBMEM_(
        LoadBMem,
        ReadData2,
        MEM_Data_Reg_Out,
        DataRegB
    );

    Registrador A_(
        clk,
        reset,
        A_w,
        DataRegA,
        A_out
    );

    Registrador B_(
        clk,
        reset,
        B_w,
        DataRegB,
        B_out
    );

    mux_ALUsrcA MUX_ALUSRCA_(
        AluSrcA,
        PC_out,
        A_out,
        Data_In_Ula_A
    );

    mux_ALUsrcB MUX_ALUSRCB_(
        AluSrcB,
        B_out,
        Shift_Left2_32_Out,
        Sign_extend_out3,
        Data_In_Ula_B
    );

    ula32 ULA_(
        Data_In_Ula_A,
		Data_In_Ula_B,
		AluOP,
		Result_ULA, 
		Overflow_ULA,
		Negativo_ULA,
		Zero_ULA,
		Igual_ULA,
        Maior_ULA,
		Menor_ULA
    );

    Registrador ALU_OUT_(
        clk,
        reset,
        AluOutWrite,
        Result_ULA,
        AluOut_Out
    );

    Registrador EPC_(
        clk,
        reset,
        EPCWrite,
        Result_ULA,
        EPC_Out
    );

    Brancher BRANCHER_(
        BranchOp,
        Instr15_0,  // endereço
        AluOut_Out, // PC+4
        Maior_ULA,
		Menor_ULA,
        Igual_ULA,
        Brancher_Out
    ); 

    mux_PCsrc MUX_PCSRC_(
        PCSource,
        Result_ULA,
        AluOut_Out,
        Concat_32_out,
        EPC_Out,
        Brancher_Out,
        PC_in
    ); 

    sign_extend1to32 SIGN_EXTEND1TO32_(
        Menor_ULA,
        Menor_Ula_Extend
    );

    sign_extend16to32 SIGN_EXTEND16TO32_1_(
        B_out[15:0],
        Sign_extend_out1
    );

    sign_extend8to32 SIGN_EXTEND8TO32_2_(
        B_out[7:0],
        Sign_extend_out2
    );

    mux_ByteHalfword MUX_BH_(
       MuxBH,
       Sign_extend_out1,
       Sign_extend_out2,
       Mux_BH_Out
    );

    mux_WriteData WDMUX_(
        WDMUX,
        B_out,
        Mux_BH_Out,
        Wd_mux_out
    );

    mux_ShiftInput MUX_SHIFT_INPUT_(
        MuxShiftInput,
        B_out,
        A_out,
        Sign_extend_out3,
        RegShift_Entrada
    );

    mux_ShiftQtd MUX_SHIFT_QTD_(
        MuxShiftQtd,
        MEM_Data_Reg_Out[4:0],
        Instr15_0[10:6],
        B_out[4:0],
        RegShift_N
    );
    
    RegDesloc REG_DESLOC_(
        clk,
		reset,
		Shift,
		RegShift_N,
		RegShift_Entrada, 
		RegDesloc_Out
    );

    mux_ExtendOp MUX_EXTEND_OP_(
        ExtendOP,
        MEM_Data_Reg_Out[15:0],
        Instr15_0,
        Mux_ExtendOp_Out
    );

    sign_extend16to32 SIGN_EXTEND16TO32_3_(
        Mux_ExtendOp_Out,
        Sign_extend_out3
    );

    sign_extend8to32 SIGN_EXTEND8TO32_4_(
        MEM_Data_Reg_Out[7:0],
        Sign_extend_out4
    );

    shift_left2_32to32 SHIFT_LEFT_32_(     
        Sign_extend_out3,
        Shift_Left2_32_Out
    );

    concat25b CONCAT25BITS_(
        Instr15_0,
        Instr25_21,
        Instr20_16,
        Concat_25b_out
    );

    shift_left2_26to28 SHIFT_LEFT_26_(
        Concat_25b_out,
        Shift_Left2_26_Out
    );

    concat32b CONCAT32BITS_(
        PC_out[31:28],
        Shift_Left2_26_Out,
        Concat_32_out
    );

    mux_memToReg MUX_MEM_TO_REG_(
        MemToReg,
        MEM_Data_Reg_Out,
        Sign_extend_out3,
        Sign_extend_out4,
        RegDesloc_Out,
        Menor_Ula_Extend,
        AluOut_Out,
        Reg_Hi_Out,
        Reg_Low_Out,
        WriteData
    );

    mult MULT_(
        A_out,
        B_out,
        clk,
        Mult_hi_out,
        Mult_low_out
    );

    div DIV_(
        clk,
        reset,
        A_out,
        B_out,
        Div_hi_out,
        Div_low_out
    );

    mux_HI MUX_HI_(
        OPhi,
        Div_hi_out,
        Mult_hi_out,
        mux_hi_out
    );
    
    mux_LOW MUX_LOW_(
        OPlow,
        Div_low_out,
        Mult_low_out,
        mux_low_out
    );

    Registrador HI_(
        clk,
        reset,
		HIWrite,
        mux_hi_out,
        Reg_Hi_Out
    );

    Registrador LOW_(
        clk,
        reset,
		LOWrite,
        mux_low_out,
        Reg_Low_Out
    );

    mux_INTCause MUX_INT_CAUSE_(
        INTCause,
        Cause_out
    );
    
     Registrador CAUSE(
        clk,
        reset,
		CauseWrite,
        Cause_out,
        Reg_Cause_out
    );

    and_or AND_OR_(
        Zero_ULA,
        PCWriteCond,
        PCWrite,
        PC_w
    );

endmodule