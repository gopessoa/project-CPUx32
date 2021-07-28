module mult (
    input wire [31:0] multiplicand,
    input wire [31:0] multiplier,
    input wire clock,
    input wire start,

    output wire [31:0] hi,
    output wire [31:0] low,
    output busy;

);
    // m = multiplicand, q = multiplier, r = result
    // c = count
    reg [31:0] m, q, r; 
    reg [31:0] c;
    reg test;
    
    wire [31:0] sum, diff;

    always @(posedge clock) begin
      if (start) begin
        m <= multiplicand;
        q <= multiplier;
        r <= 32'b0;
        test <= 1'b0;
        c <= 32'b0;
      end 
      else begin
        case ({q[0], test})
        2'b0_1 : {r, q, test} <= {sum[31], sum, q};
        2'b1_0 : {r, q, test} <= {diff[31], diff, q};
        default: {r, q, test} <= {r[31], r, q};
        endcase
        c <= c + 1'b1;
      end
    end

    alu add (r, m, 1'b0, sum);
    alu sub (r, ~m, 1'b1, diff);

    assign hi = {r, q}[31:0];
    assign low = {r, q}[64:32]
    assign busy = {c < 32};

endmodule

//alu para as operações de soma e subtração
//cin = carry-in
module alu(
    input [31:0] a;
    input [31:0] b;
    input cin;
    output [31:0] out;
);
    assign out = a + b + cin;
endmodule