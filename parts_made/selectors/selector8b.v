module selector8b(
    input wire [31:0] data_in,
    output wire[7:0] data_out
)

    assign data_out = data_in[7:0];

endmodule