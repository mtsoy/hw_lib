`ifndef __LIFO_BUFFER__
`define __LIFO_BUFFER__

module lifo_buffer #(
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
logic [HEAD_POINTER_W-1:0] head_pointer, address_to_write;
logic isPushAllowed, isPopAllowed;

/* BUFFER SCHEME */
always_comb begin
    isPushAllowed = push;
    if(full && !pop)
        isPushAllowed = 1'b0;

    isPopAllowed = pop;
    if(empty)
        isPopAllowed = 1'b0;

    address_to_write = head_pointer;
    if(isPopAllowed)
        address_to_write = head_pointer-1;
end

always_ff @(posedge clock)
    if(reset)
        head_pointer <= '0;
    else if(isPushAllowed && !isPopAllowed)
        head_pointer <= head_pointer + 1'b1;
    else if(!isPushAllowed && isPopAllowed)
        head_pointer <= head_pointer - 1'b1;

genvar Gi;
generate
    for(Gi = 0; Gi < BUFFER_SIZE; Gi = Gi+1) begin: writting_buffer
        always_ff @(posedge clock)
            if(isPushAllowed)
                buffer[Gi] <= (address_to_write == Gi) ? data_in : buffer[Gi];
    end
endgenerate

/* OUTPUTS SCHEME */
always_ff @(posedge clock)
    if(pop && !empty) begin
        data_out <= buffer[head_pointer-1];
        val <= 1'b1;
    end
    else begin
        val <= 1'b0;
    end

always_comb begin
    full = (head_pointer == BUFFER_SIZE);
    empty = (head_pointer == 0);
end

endmodule
`endif
