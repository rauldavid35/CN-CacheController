module tag_array (
    input clk,
    input [6:0] set_index,
    input [18:0] tag,
    input write_enable,
    input read,
    input [1:0] update_way,
    output reg hit,
    output reg [1:0] way
);

    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;
    parameter TAG_BITS = 19;

    reg [TAG_BITS-1:0] tag_array[NUM_SETS * ASSOCIATIVITY - 1:0];
    reg valid_array[NUM_SETS * ASSOCIATIVITY - 1:0];

    integer i;

    initial begin
        for (i = 0; i < NUM_SETS * ASSOCIATIVITY; i = i + 1) begin
            valid_array[i] = 0;
        end
    end

    always @(*) begin
        hit = 0;
        way = 0;
        if (read) begin
            for (i = 0; i < ASSOCIATIVITY; i = i + 1) begin
                if (valid_array[set_index * ASSOCIATIVITY + i] && tag_array[set_index * ASSOCIATIVITY + i] == tag) begin
                    hit = 1;
                    way = i;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (write_enable) begin
            tag_array[set_index * ASSOCIATIVITY + update_way] <= tag;
            valid_array[set_index * ASSOCIATIVITY + update_way] <= 1;
        end
    end
endmodule
