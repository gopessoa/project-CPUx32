module mux_HI(
    input wire selector,
    input wire [31:0] data_divLOW,
    input wire [31:0] data_multLOW,
    output wire [31:0] data_out
);

    assign data_out = (selector) ? data_multLOW : data_divLOW; 

endmodule