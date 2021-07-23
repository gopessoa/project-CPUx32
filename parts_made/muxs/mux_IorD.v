module mux_IorD(

    input wire selector,
    input wire data_0,
    input wire data_1,
    output wire data_out
);

    assign data_out = (selector) ? data_1 : data_0; 
    
endmodule 