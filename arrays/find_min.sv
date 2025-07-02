`ifndef __FIND_MIN__
`define __FIND_MIN__

module find_min #(
    parameter ARRAY_SIZE = -1,
    parameter DATA_WIDTH = -1
)(
    input  logic [DATA_WIDTH-1:0] array [ARRAY_SIZE-1:0],
    output logic [DATA_WIDTH-1:0] min
);

genvar Gi;
generate
    if(ARRAY_SIZE == 1) begin: recursive_exit
        assign min = array[0];
    end
    else begin: recursive_call
        localparam HALF_ARRAY_SIZE = (ARRAY_SIZE / 2) + (ARRAY_SIZE % 2);
        logic [DATA_WIDTH-1:0] tmp [HALF_ARRAY_SIZE-1:0];

        for(Gi = 0; Gi < ARRAY_SIZE-1; Gi = Gi+2) begin: pairwise_compare
            assign tmp[Gi/2] = (array[Gi] < array[Gi+1]) ? array[Gi] : array[Gi+1];
        end

        if(ARRAY_SIZE % 2) begin: last_uncompared
            assign tmp[HALF_ARRAY_SIZE-1] = array[ARRAY_SIZE-1];
        end

        find_min #(HALF_ARRAY_SIZE, DATA_WIDTH) next_stage (
            .array (tmp),
            .min   (min)
        );
    end
endgenerate

endmodule

`endif
