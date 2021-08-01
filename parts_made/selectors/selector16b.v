module selector16b (
    input wire [31:0] data_in,
    output wire [15:0] data_out
);
    
    assign data_out = data_in[15:0];

endmodule