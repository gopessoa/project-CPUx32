module mux_ALUsrcA(
    input wire             selector,
    input wire      [31:0] data_pc,
    input wire      [31:0] data_memA,
    output wire     [31:0] src_A
);

    assign src_A = (selector) ? data_memA : data_pc;

endmodule
