`ifndef __BUBBLE_SORT__
`define __BUBBLE_SORT__

module bubble_sort #(
    parameter ARRAY_SIZE = -1,
    parameter DATA_WIDTH = -1
)(
    input  logic [DATA_WIDTH-1:0] in  [ARRAY_SIZE-1:0],
    output logic [DATA_WIDTH-1:0] out [ARRAY_SIZE-1:0]
);

logic [DATA_WIDTH-1:0] tmp [ARRAY_SIZE-1:0][ARRAY_SIZE-1:0];
always_comb begin
    for(int i = 0; i < ARRAY_SIZE; i++)
        tmp[0][i] = in[i];
end

genvar Gi, Gj;
generate
    for(Gi = 1; Gi < ARRAY_SIZE; Gi = Gi+1) begin: stage
        for(Gj = (Gi-1)%2; Gj < ARRAY_SIZE-1; Gj = Gj+2) begin: swapping
            wire swap = (tmp[Gi-1][Gj] > tmp[Gi-1][Gj+1]);
            always_comb begin
                if(swap) begin
                    tmp[Gi][Gj]   = tmp[Gi-1][Gj+1];
                    tmp[Gi][Gj+1] = tmp[Gi-1][Gj];
                end
                else begin
                    tmp[Gi][Gj]   = tmp[Gi-1][Gj];
                    tmp[Gi][Gj+1] = tmp[Gi-1][Gj+1];
                end
            end
        end
        if((Gi-1) % 2) begin: shifted_stage
            always_comb begin
                tmp[Gi][0] = tmp[Gi-1][0];
            end

            if(!(ARRAY_SIZE % 2)) begin: even_array_size
                always_comb begin
                    tmp[Gi][ARRAY_SIZE-1] = tmp[Gi-1][ARRAY_SIZE-1];
                end
            end
        end
    end
endgenerate

always_comb begin
    for(int i = 0; i < ARRAY_SIZE; i++)
        out[i] = tmp[ARRAY_SIZE-1][i];
end

endmodule

`endif
