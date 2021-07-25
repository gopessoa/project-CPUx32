module sign_extend8to32(
    input wire [7:0] data_in,
    output wire [31:0] data_out
);

    assign data_out = (data_in[15]) ? {{24{1'b1}}, data_in} : {{24{1'b0}}, data_in};

endmodule