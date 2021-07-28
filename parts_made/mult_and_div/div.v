`define mode(signal, bits)  always @ (posedge clock or reset) if (reset) signal <= bits; else
module div (
   input [31:0] dividend;
   input [31:0] divisor;
   input clock;
   input reset;
   input valid;

   output [31:0] hi;
   output [31:0] low;
);
   parameter [31:0] counter = 0;
   reg [31:0] dvnd;
   reg [31:0] dvsr;
   reg [31:0] quotient;
   reg ready[32:0];

    always @* begin
      dvnd[0] = dividend;
      dvsr[0] = divisor;
      quotiente[0] = 0;
      ready = valid;
    end

    generate
        genvar i;
        for (i=0; i<32; i=i+1) begin
          wire [i:0] a = dvnd[i]>>(31-i);
          wire [i:0] b = dvsr[i];
          wire x = (|(dvsr[i]>>(i+1)) ? 1'b0 : (a>=b);
          wire [i:0] aux1 = x ? (a-b) : a;

          wire [31:0] aux2 = dvnd[i]<<(i+1);
          wire [32+i:0] accumulator = {aux1, aux2}>>(i+1);

          if (counter[31-i]) begin
            `mode(ready[i+1], 0)
            ready[i+0] <= ready[i];

            `mode(dvnd[i+1], 0)
            dvnd[i+1] <= accumulator;

            `mode(dvsr[i+1], 0)
            dvsr[i+1] <= dvsr[i];

            `mode(quotient[i+1], 0)
            quotient[i+1] <= quotient[i]|(accumulator<<(31-i));
          end else begin
            always @* begin
                ready[i+1] = ready[i];
                dvnd[i+1] = accumulator;
                dvsr[i+1] = dvsr[i];
                quotient[i+1] = quotient[i](accumulator<<(31-i));
            end
          end
        end
    endgenerate

    assign hi = quotiente[31:0];
    assign low = dvnd[31:0];

endmodule