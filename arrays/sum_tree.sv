`ifndef __SUM_TREE__
`define __SUM_TREE__

module sum_tree #(
    parameter ARRAY_SIZE = -1,
    parameter DATA_WIDTH = -1,

    parameter SUM_WIDTH = $clog2(ARRAY_SIZE * (2**DATA_WIDTH - 1))
)(
    input [DATA_WIDTH-1:0] array [ARRAY_SIZE-1:0],
    output [SUM_WIDTH-1:0] sum
);

localparam NEXT_ARRAY_SIZE = (ARRAY_SIZE / 2) + (ARRAY_SIZE % 2);
genvar Gi;

generate
    if(ARRAY_SIZE == 1) begin: recursive_exit
        assign sum = array[0];
    end
    else begin: recursive_call
        logic [DATA_WIDTH:0] next_array [NEXT_ARRAY_SIZE-1:0];

        for(Gi = 0; Gi < ARRAY_SIZE-1; Gi = Gi+2) begin: subsums_calculation
            assign next_array[Gi/2] = array[Gi] + array[Gi+1];
        end

        if(ARRAY_SIZE % 2) begin: last_unsummed
            assign next_array[NEXT_ARRAY_SIZE-1] = array[ARRAY_SIZE-1];
        end

        sum_tree #(
            .ARRAY_SIZE (NEXT_ARRAY_SIZE),
            .DATA_WIDTH (DATA_WIDTH + 1),
            .SUM_WIDTH  (SUM_WIDTH)
        ) next_stage (
            .array (next_array),
            .sum   (sum)
        );
    end
endgenerate

endmodule

`endif
