module mux_memToReg(
    input wire [3:0] selector,
    input wire [31:0] data_0,
    input wire [31:0] data_1,
    input wire [31:0] data_2,
    input wire [31:0] data_3,
    input wire [31:0] data_4,
    input wire [31:0] data_5,
    input wire [31:0] data_6,
    input wire [31:0] data_7,

    output wire [31:0] memToReg
);

    wire [31:0] A1; 
    wire [31:0] A2;
    wire [31:0] A3;
    wire [31:0] A4;
    wire [31:0] A5;
    wire [31:0] A6;
    wire [31:0] A7;

    assign A1 = (selector[0]) ? data_1 : data_0; 0 
    assign A2 = (selector[0]) ? data_3 : data_2; 2
    assign A5 = (selector[1]) ? A2 : A1; 0
 
    assign A3 = (selector[0]) ? data_5 : data_4; 4
    assign A4 = (selector[0]) ? data_7 : data_6; 6
    assign A6 = (selector[1]) ? A4 : A3; 4

    assign A7 = (selector[2]) ? A6 : A5; 0 

    assign memToReg = (selector[3]) ? 32'b00000000000000000000000011100011 : A7; 0


endmodule