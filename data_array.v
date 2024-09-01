module data_array (
    input clk,
    input [6:0] set_index,
    input [1:0] way,
    input [5:0] block_offset,
    input [1:0] byte_offset,
    input [31:0] write_data,
    output reg [31:0] read_data,
    input write,
    input read
);

    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;
    parameter BLOCK_SIZE = 64;
    parameter WORD_SIZE = 4;
    parameter NUM_WORDS_PER_BLOCK = BLOCK_SIZE / WORD_SIZE;

    parameter TOTAL_CACHE_LINES = NUM_SETS * ASSOCIATIVITY;

    reg [31:0] data_array[TOTAL_CACHE_LINES * NUM_WORDS_PER_BLOCK - 1:0];

    wire [3:0] word_offset;
    assign word_offset = block_offset[5:2];

    wire [11:0] base_index;
    assign base_index = (set_index * ASSOCIATIVITY + way) * NUM_WORDS_PER_BLOCK;

    always @(posedge clk) begin
        if (read) begin
            read_data <= data_array[base_index + word_offset];
        end
        if (write) begin
            data_array[base_index + word_offset] <= write_data;
        end
    end
endmodule
