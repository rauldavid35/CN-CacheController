module lru_module (
    input clk,
    input [6:0] set_index,
    input [1:0] way,
    output reg [1:0] update_lru
);

    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;

    reg [1:0] lru_counter[NUM_SETS * ASSOCIATIVITY - 1:0];

    integer i;

    always @(posedge clk) begin
        for (i = 0; i < ASSOCIATIVITY; i = i + 1) begin
            if (i == way) begin
                update_lru = lru_counter[set_index * ASSOCIATIVITY + i];
                lru_counter[set_index * ASSOCIATIVITY + i] = ASSOCIATIVITY - 1;
            end else if (lru_counter[set_index * ASSOCIATIVITY + i] < lru_counter[set_index * ASSOCIATIVITY + way]) begin
                lru_counter[set_index * ASSOCIATIVITY + i] = lru_counter[set_index * ASSOCIATIVITY + i] + 1;
            end
        end
    end
endmodule
