module mux_PCsrc (
    input wire [2:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] data_4,
    input wire [31:0] data_5,
    output wire [31:0] out
);

    wire [31:0] A1;
    wire [31:0] A2;
    wire [31:0] A3;
    wire [31:0] A4;

    assign A1 = (selector[0]) ? data_1 : data_0;
    assign A2 = (selector[0]) ? 32'b00000100110001001011010010110100 : data_2;
    assign A3 = (selector[0]) ? data_5 : data_4;

    assign A4 = (selector[1]) ? A2 : A1;
    assign out = (selector[2]) ? A3 : A4;

endmodule

