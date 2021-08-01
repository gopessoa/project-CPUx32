module Brancher(
    input wire [1:0]    BranchOP, // op da UC
    input wire [15:0]   adress,
    input wire [31:0]   ALU_out, // PC+4
    input wire GT,
    input wire LT,
    input wire ET,
    output wire [31:0]  Brancher_out // SAIDA

);

    parameter beq = 2'b00;
    parameter bne = 2'b01;
    parameter bgt = 2'b10;
    parameter ble = 2'b11;
    
    wire [31:0] aux = {{16{1'b0}}, adress};
    wire [31:0] offset = aux<<2;
    wire [31:0] saida = offset + ALU_out;
    // beq, bne, bgt, ble
    reg RESULT;

    always @(*) begin
        case(BranchOP)
        beq: begin
          RESULT = ET;
        end
        bne: begin
          RESULT = ~ET;
        end
        bgt: begin
           RESULT = GT;
        end
        ble: begin
            RESULT = LT | ET;
        end  
    endcase
    end
    
    assign Brancher_out = (RESULT) ? saida : ALU_out;

endmodule