`ifndef __FIFO_BUFFER__
`define __FIFO_BUFFER__

module fifo_buffer #(
    parameter BUFFER_SIZE = -1,
    parameter DATA_WIDTH  = -1
)(
    input logic clock,
    input logic reset,
    input logic push,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic pop,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic val,
    output logic full,
    output logic empty
);

localparam HEAD_POINTER_W = $clog2(BUFFER_SIZE+1);

logic [DATA_WIDTH-1:0] buffer [BUFFER_SIZE-1:0];
logic [HEAD_POINTER_W-1:0] w_pointer, r_pointer;
logic isPushAllowed, isPopAllowed;
logic isLastCmdPush;
[O
/* BUFFER SCHEME */
always_comb begin
    isPushAllowed = push;
    if(full && !pop)
        isPushAllowed = 1'b0;

    isPopAllowed = pop;
    if(empty)
        isPopAllowed = 1'b0;
end

always_ff @(posedge clock)
    if(reset)
        w_pointer <= '0;
    else if(isPushAllowed)
        w_pointer <= (w_pointer == BUFFER_SIZE-1) ? '0 : w_pointer + 1'b1;

always_ff @(posedge clock)
    if(reset)
        r_pointer <= '0;
    else if(isPopAllowed)
        r_pointer <= (r_pointer == BUFFER_SIZE-1) ? '0 : r_pointer + 1'b1;

always_ff @(posedge clock)
    if(reset)
        isLastCmdPush <= 1'b0;
    else if(isPushAllowed)
        isLastCmdPush <= 1'b1;
    else if(isPopAllowed)
        isLastCmdPush <= 1'b0;

genvar Gi;
generate
    for(Gi = 0; Gi < BUFFER_SIZE; Gi = Gi+1) begin: writting_buffer
        always_ff @(posedge clock)
            if(isPushAllowed)
                buffer[Gi] <= (w_pointer == Gi) ? data_in : buffer[Gi];
    end
endgenerate

/* OUTPUTS SCHEME */
always_ff @(posedge clock)
    if(isPopAllowed) begin
        data_out <= buffer[r_pointer];
        val <= 1'b1;
    end
    else begin
        val <= 1'b0;
    end

always_comb begin
    full  = (w_pointer == r_pointer) &&  isLastCmdPush;
    empty = (w_pointer == r_pointer) && !isLastCmdPush;
end

endmodule
`endif
