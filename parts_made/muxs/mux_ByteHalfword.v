module mux_ByteHalfword(
    input  wire selector,
    input  wire [31:0] data_Halfword,
    input  wire [31:0] data_Byte,
    output wire [31:0] data_out
);

    assign data_out = (selector) ? data_Byte : data_Halfword;

endmodule