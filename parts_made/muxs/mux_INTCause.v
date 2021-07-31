module mux_INTCause(

    input wire selector,
    output wire data_out
);

    assign data_out = (selector) ? 32'b00000000000000000000000000000001 : 32'b00000000000000000000000000000000; 
    
endmodule 