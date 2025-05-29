/* AUTHOR:     		git: mtsoy, email: tsoy.mo@phystech.edu
 *
 * DESCRIPTION:     	The module calculates the position of '1' in a vector given.
 *                  	Works correctly only for vectors that contain not more than one '1'.
 *						If there are no '1' in the vector the answer is supposed to be zero. 
 */

module onehot_dec #(
    parameter VECTOR_W   = 4,
    parameter POSITION_W = $clog2(VECTOR_W)
)(
    input  [VECTOR_W  -1:0] vector,
    output [POSITION_W-1:0] position
);

logic [POSITION_W-1:0] mask [VECTOR_W -1:0];
logic [POSITION_W-1:0] nums [VECTOR_W -1:0];

logic [VECTOR_W -1:0] matrix [POSITION_W-1:0]; // transposed for calculating the answer with fast parallel design

genvar Gi, Gj;
generate
    for(Gi = 0; Gi < VECTOR_W; Gi = Gi+1) begin: row
        assign mask[Gi] = {POSITION_W{vector[Gi]}};
        assign nums[Gi] = Gi;

        for(Gj = 0; Gj < POSITION_W; Gj = Gj+1) begin: col
            assign matrix[Gj][Gi] = nums[Gi][Gj] & mask[Gi][Gj];
        end
    end

    for(Gj = 0; Gj < POSITION_W; Gj = Gj+1) begin: assigning_output
        assign position[Gj] = |matrix[Gj];
    end
endgenerate

endmodule

