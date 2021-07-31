module mult (
    input [31:0] a,
    input [31:0] b,
    input clock,
    output [31:0] hi,
    output [31:0] low
);
    parameter bits = 32;
    parameter counter = bits/2;
    reg [2:0] test_case[counter-1:0];
    reg [32:0] collection_1[counter-1:0];
    reg [63:0] accumulator[counter-1:0];
    reg [63:0] product;

    wire [32:0] inv_a;
    integer i, j;

    assign inv_a = {~a[31], ~a}+1;

    always @(posedge clock) begin
      test_case[0] = {b[1], b[0], 1'b0};
      for(i=1; i<counter; i=i+1)
      test_case[i] = {b[2*i+1], b[2*i], b[2*i-1]};
      for(i=0; i<counter; i=i+1)
        begin
          case(test_case[i])
            3'b001 , 3'b010 : collection_1[i] = {a[31], a};
            3'b011 : collection_1[i] = {a, 1'b0};
            3'b100 : collection_1[i] = {inv_a[31:0], 1'b0};
            3'b101 , 3'b110 : collection_1[i] = inv_a;
            default : collection_1[i] = 0;
          endcase

          accumulator[i] = $signed (collection_1[i]);
          for(j=0; j<i; j=j+1)
          accumulator[i] = {accumulator[i], 2'b00};
        end
        product = accumulator[0];
        for (i=1; i<counter; i=i+1)
        product = product + accumulator[i];
    end

    assign hi = product[31:0];
    assign low = product[63:32];

endmodule