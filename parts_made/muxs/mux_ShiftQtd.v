module mux_ShiftQtd(
    input wire [1:0] selector,
    input wire [4:0] data_0,
    input wire [4:0] data_1,
    input wire [4:0] data_2,
    output wire [4:0] data_out
);

    wire [4:0] A1;
    wire [4:0] A2;

    assign A1 = (selector[0]) ? data_1 : data_0;
    assign A2 = (selector[0]) ? 5b'10000 : data_2;
    assign data_out = (selector[1]) ? A2 : A1;

endmodule

