module and_or(
    input wire zero,
    input wire pc_write_cond,
    input wire pc_write,
    output wire Pc_w
);

    assign Pc_w = (pc_write_cond & zero) | pc_write;
    
endmodule