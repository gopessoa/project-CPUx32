module concat32b (
    input wire [3:0] data_0,
    input wire [27:0] data_1,
    output wire [31:0] data_out
);
    
    assign data_out = {data_0, data_1};

endmodule