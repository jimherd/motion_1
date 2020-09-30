//
// clock_gen_1.sv : 12.5MHz
//
// Generate 12.5MHz clock from system 50MHz clock
//
module clock_gen_1(clk_in, clk_out);
input logic clk_in;
output logic  clk_out;

reg [2:0] count_reg = 0;

always_ff @(posedge clk_in) begin

        if (count_reg < 2) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            clk_out <= ~clk_out;
        end
    end
endmodule
