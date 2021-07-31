module brancher(

    input wire [1:0]    BranchOP; // op da UC
    input wire [31:0]   adress;
    input wire [31:0]   ALU_out; // PC+4
    input wire GT;
    input wire LT;
    input wire ET;

    output wire [31:0]  brancher_out; // SAIDA

);
    // beq, bne, bgt, ble
    wire RESULT;

    if(branchOP == 0)begin //beq
        assign RESULT = ET;
    end
    if(branchOP == 1)begin //bne
        assign RESULT = ~ET;
    end
    if(branchOP == 2)begin //bgt
        assign RESULT = GT;
    end
    if(branchOP == 3)begin //ble
        assign RESULT = LT && ET;
    end

    assign Brancher_out = (RESULT) ? adress : ALU_out;

endmodule