module shift_left2_26to28(
    input wire [25:0] data_in,
    output wire [27:0] data_out
);

    wire [27:0] A1;

    assign A1 = {{2{1'b0}}, data_in};
    assign data_out = A1 << 2;

endmodule