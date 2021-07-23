module mux_ALUsrcB(
    input wire      [1:0]  selector,
    input wire      [31:0] data_memB,
    input wire      [31:0] data_sgnExtnd,
    input wire      [31:0] data_shiftL2,
    output wire     [31:0] src_B
);
    wire [31:0] A1;
    wire [31:0] A2;

    assign A1 = (selector) ? 32'b00000000000000000000000000000100 : data_memB;
    assign A2 = (selector) ? data_sgnExtnd : A1;
    assign src_B = (selector[1]) ? data_shiftL2 : A2 ;

endmodule