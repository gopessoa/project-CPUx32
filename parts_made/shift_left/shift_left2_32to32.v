   module shift_left2_32to32(
    input wire [31:0] data_in,
    output wire [31:0] data_out
);

    assign data_out = data_in << 2;

endmodule