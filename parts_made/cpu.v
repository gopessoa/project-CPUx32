module cpu(
    input wire clk,
    input wire reset
);
// Fios de Controle
    wire PC_w; //Adicionado
    wire A_w; //Adicionado
    wire B_w; //Adicionado
    wire WDMux; //Adicionado
    wire MemDataRegLoad; //Adicionado
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

    wire [15:0] Instr15_0;
    wire [15:0] MEM_Data_Reg_Out;
    wire [15:0] Mux_ExtendOp_Out;

    wire [5:0] Instr31_26;
    wire [5:0] WriteReg;

    wire [4:0] Instr25_21;
	wire [4:0] Instr20_16;

    wire Overflow_ULA;
	wire Negativo_ULA;
    wire Zero_ULA;
    wire Igual_ULA;
    wire Maior_ULA;
	wire Menor_ULA;
    
    Registrador PC_(
        clk,
        reset,
        PC_w,
        PC_in,
        PC_out
    );

    mux_IorD MUX_IORD_(
        PC_out,      
        AluOut_Out,
        B_out,
        data_3, //ADICIONAR FIO
        A_out
    );

    Memoria MEM_(
        PC_out,
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
        Instr31_26,
		Instr25_21,
		Instr20_16,
		Instr15_0
    );

    mux_RegDST MUX_REGDST_(
        RegDst,
        Instr20_16,
        Instr15_0[15:11], //Verificar se funciona
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
        LoadAMem,
        ReadData1,
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
        DATA_0, //ADICIONAR FIO
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
		AluOp,
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

    Brancher BRANCHER_( //NÂO TEMOS ESSA UNIDADE AINDA	
        Maior_ULA,
		Menor_ULA,
        Igual_ULA,
        AluOut_Out,
        Instr15_0,
        Brancher_Out
    ); 

    mux_PCsrc MUX_PCSRC_(
        PCSource,
        Result_ULA,
        AluOut_Out,
        data_2, //ADICIONAR FIO EXCEPTION ADDRESS
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
        MEM_Data_Reg_Out,
        Instr15_0[10:6],
        data_2, //????????????????????????
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


endmodule