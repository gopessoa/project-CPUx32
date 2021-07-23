module mux_HI(
    input wire selector,
    input wire [31:0] data_divHI,
    input wire [31:0] data_multHI,
    output wire [31:0] data_out
);

    assign data_out = (selector) ? data_multHI : data_divHI; 

endmodule