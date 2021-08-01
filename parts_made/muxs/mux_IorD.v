module mux_IorD(
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] data_3,
    input wire [31:0] data_4,
    output wire [31:0] mux_iord_out
);


    wire [31:0] A1;
    wire [31:0] A2;
    wire [31:0] A3;
    wire [31:0] A4;

    assign A1 = (selector[0]) ? data_1 : data_0;
    assign A2 = (selector[0]) ? data_3 : data_2;
    assign A3 = (selector[1]) ? A2 : A1;
    assign mux_iord_out = (selector[2]) ? data_4 : A3;

endmodule