// 
// Two flip-flop synchroniser
//
module synchronizer (
    output logic sync_out,
    input  logic async_in, clk, reset);
    
logic q1; // 1st stage ff output

always_ff @(posedge clk or negedge reset)
    if (!reset) 
        {sync_out,q1} <= '0;
    else 
        {sync_out,q1} <= {q1,async_in};
        
endmodule