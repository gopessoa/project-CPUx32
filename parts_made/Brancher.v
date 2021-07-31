module Brancher(
    input wire [1:0]    BranchOP, // op da UC
    input wire [15:0]   adress,
    input wire [31:0]   ALU_out, // PC+4
    input wire GT,
    input wire LT,
    input wire ET,
    output wire [31:0]  Brancher_out // SAIDA

);

    parameter IS_ET = 2'b00;
    parameter IS_notET = 2'b01;
    parameter IS_GT = 2'b10;
    parameter IS_LT = 2'b11;
    // beq, bne, bgt, ble
    reg RESULT;

    always @(*) begin
        case(BranchOP)
        IS_ET: begin
          RESULT = ET;
        end
        IS_notET: begin
          RESULT = ET;
        end
        IS_GT: begin
           RESULT = GT;
        end
        IS_LT: begin
            RESULT = LT;
        end  
    endcase
    end


    
    assign Brancher_out = (RESULT) ? adress : ALU_out;

endmodule