module mux_ShiftInput(
    input wire [1:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    output wire [31:0] data_out
);

    wire [31:0] A1;

    assign A1 = (selector[0]) ? data_1 : data_0;
    assign data_out = (selector[1]) ? data_2 : A1;

endmodule