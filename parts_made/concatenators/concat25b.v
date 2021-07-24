module concat25b (
    input wire [15:0] data_0,
    input wire [4:0] data_1
    input wire [4:0] data_2
    output wire [25:0] data_out
);

    wire [20:0] aux;

    assign aux = {data_1, data_0};
    assign data_out = {data_2, aux};

endmodule
