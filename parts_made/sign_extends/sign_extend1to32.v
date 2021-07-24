module sign_extend1to32(
    input wire data_int,
    output wire [31:0] data_out
);

    assign data_out = (data_in) ? {{31{1'b1}}, data_in} : {{31{1'b0}}, data_in}

endmodule