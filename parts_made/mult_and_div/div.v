`define F(n) [(n)-1:0]
`define mode(signal, value)  always @ (posedge clock or posedge reset) if (reset) signal <= value; else
module div
 #(
   parameter bits = 32,
   parameter `F(bits) counter = 0
   )(
   input `F(bits) dividend,
   input `F(bits) divisor,
   input clock,
   input reset,
   input valid,

   output `F(bits) hi,
   output `F(bits) low
);
   reg `F(bits) dvnd `F(bits+1);
   reg `F(bits) dvsr `F(bits+1);
   reg `F(bits) quotient `F(bits+1);
   reg ready `F(bits+1);

    always @* begin
      dvnd[0] = dividend;
      dvsr[0] = divisor;
      quotient[0] = 0;
      ready[0] = valid;
    end

    generate
        genvar i;
        for (i=0; i<32; i=i+1) begin:gen_div
          wire [i:0] a = dvnd[i]>>(31-i);
          wire [i:0] b = dvsr[i];
          wire x = (|(dvsr[i]>>(i+1))) ? 1'b0 : (a>=b);

          wire [i:0] aux1 = x ? (a-b) : a;

          wire [31:0] aux2 = dvnd[i]<<(i+1);

          wire [32+i:0] accumulator = {aux1, aux2}>>(i+1);

          if (counter[31-i]) begin:gen_ff
            `mode(ready[i+1], 0)
            ready[i+1] <= ready[i];

            `mode(dvnd[i+1], 0)
            dvnd[i+1] <= accumulator;

            `mode(dvsr[i+1], 0)
            dvsr[i+1] <= dvsr[i];

            `mode(quotient[i+1], 0)
            quotient[i+1] <= quotient[i]|(accumulator<<(31-i));
          end else begin:gen_comb
            always @* begin
                ready[i+1] = ready[i];
                dvnd[i+1] = accumulator;
                dvsr[i+1] = dvsr[i];
                quotient[i+1] = quotient[i]|(x<<(31-i));
            end
          end
        end
    endgenerate

    assign hi = quotient[32];
    assign low = dvnd[32];


endmodule