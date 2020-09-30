module bus_32_mux
 #( parameter int unsigned inputs = 4,
    parameter int unsigned width = 8 )
  ( output logic [width-1:0] out,
    input logic sel[inputs],
    input logic [width-1:0] in[inputs] );

    always_comb
    begin
        out = {width{1'b0}};
        for (int unsigned index = 0; index < inputs; index++)
        begin
            out |= {width{sel[index]}} & in[index];
        end
    end
endmodule