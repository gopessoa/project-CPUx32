module mux_ALUsrcB(
    input wire      [1:0]  selector,
    input wire      [31:0] data_memB,
    input wire      [31:0] data_sgnExtnd,
    input wire      [31:0] data_shiftL2,
    output wire     [31:0] src_B
);
    wire [31:0] A1;
    wire [31:0] A2;

    assign A1 = (selector[0]) ? 32'b00000000000000000000000000000100 : data_memB;
    assign A2 = (selector[0]) ? data_sgnExtnd : data_shiftL2;
    assign src_B = (selector[1]) ?  A2 : A1 ;

endmodule