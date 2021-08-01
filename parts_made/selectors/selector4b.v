module selector4b (
    input wire [31:0] data_in,
    output wire [3:0] data_out
);
    
    assign data_out = data_in[3:0];
    
endmodule