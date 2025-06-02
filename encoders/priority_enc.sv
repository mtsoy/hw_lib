`ifndef __PRIORITY_DECODER__
`define __PRIORITY_DECODER__

`include "onehot_enc.sv"

module priority_enc #(
    parameter VECTOR_W   = 8,
    parameter POSITION_W = $clog2(VECTOR_W)
)(
    input  [VECTOR_W  -1:0] vector,
    output [POSITION_W-1:0] position
);

logic [VECTOR_W-1:0] reverse_in;
logic [VECTOR_W-1:0] onehot, reverse_onehot;

always_comb  begin
    reverse_in = { << {vector} };
    reverse_onehot = (~(reverse_in) + 1) & reverse_in;
    onehot = { << {reverse_onehot} };
end

onehot_enc #(VECTOR_W)
onehot_enc (
    .vector   (onehot),
    .position (position)
);

endmodule

`endif
