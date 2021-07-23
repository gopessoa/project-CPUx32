module mux_ExtendOp(
    input wire             selector,
    input wire      [15:0] data_0,
    input wire      [15:0] data_1,
    output wire     [15:0] data_out
);
    assign data_out = (selector) ? data_1 : data_0;

endmodule
