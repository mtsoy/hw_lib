`ifndef __UNIQUE_HISTORY__
`define __UNIQUE_HISTORY__

`include "encoders/onehot_enc.sv"

module unique_history #(
    parameter DATA_W = -1,
    parameter HISTORY_L = -1
)(
    input  logic clock,
    input  logic reset,
    input  logic [DATA_W-1:0] data_in,
    output logic [DATA_W-1:0] data_out [HISTORY_L-1:0] ,
    output logic [HISTORY_L-1:0] valid_out
);

localparam HISTORY_L_W = $clog2(HISTORY_L);

logic [DATA_W-1:0] buffer [HISTORY_L-1:-1]; // index '-1' for next new value
logic [HISTORY_L-1:0] valid_vector;
logic isDataUniq; // 0 - if buffer[:0] already contains valid value equal to data_in
logic [HISTORY_L_W-1:0] old_position; // previous position of data_in value in buffer (if it would be in)

/* UPDATE VALUES SCHEME  */
always_comb begin
    buffer[-1] = data_in;
end

genvar Gi;
generate
    for(Gi = 0; Gi < HISTORY_L; Gi = Gi+1) begin: writting_buffer
        wire shift = isDataUniq | (old_position >= Gi); // if new value is unique, all buffer elements are to be shifted
                                                        // if new value is not unique, only elements "above" deleted one
                                                        // (it is a previous position of new value) are to be shifted
        always_ff @(posedge clock)
            if(reset)
                buffer[Gi] <= '0;
            else if(shift)
                buffer[Gi] <= buffer[Gi-1];
    end
endgenerate

/* UPDATE VALID SCHEME */
always_ff @(posedge clock)
    if(reset)
        valid_vector <= '0;
    else if(isDataUniq)
        valid_vector <= (valid_vector << 1) | 1'b1;

/* HELP SIGNALS SCHEME */
wire [HISTORY_L-1:0] overlap_vector; // 1 in i-th bit - if i-th buffer element is valid and the same as new
                                  // NOTE: it always contains not more than 1 bit which is equal to '1'
                                  //       because all valid elements are different, so only 1 of them
                                  //       could be the same as data_in
generate
    for(Gi = 0; Gi < 4; Gi = Gi+1) begin: analyzing_buffer
        assign overlap_vector[Gi] = valid_vector[Gi] & (data_in == buffer[Gi]);
    end
endgenerate

assign isDataUniq = ~|overlap_vector; // all bits are zero in overlap_vector => no coincidence, data_in is unique

onehot_enc #(
    .VECTOR_W (HISTORY_L)
) encoder (
    .vector_in (overlap_vector),
    .position  (old_position)
);

/* OUTPUTS ASSIGNING */
always_comb begin
    for(int i = 0; i < HISTORY_L; i++) begin
        data_out[i] = buffer[i];
        valid_out[i] = valid_vector[i];
    end
end

endmodule

`endif
