module cache_controller (
    input clk,
    input reset,
    input read,
    input write,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data,
    output hit,
    output miss
);

    parameter CACHE_SIZE = 32 * 1024;
    parameter BLOCK_SIZE = 64;
    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;
    parameter BLOCK_OFFSET_BITS = 6;
    parameter SET_INDEX_BITS = 7;
    parameter TAG_BITS = 32 - BLOCK_OFFSET_BITS - SET_INDEX_BITS;

    wire [SET_INDEX_BITS-1:0] set_index;
    wire [TAG_BITS-1:0] tag;
    wire [BLOCK_OFFSET_BITS-1:0] block_offset;
    wire [1:0] byte_offset;

    assign set_index = address[BLOCK_OFFSET_BITS +: SET_INDEX_BITS];
    assign tag = address[31 -: TAG_BITS];
    assign block_offset = address[BLOCK_OFFSET_BITS-1:0];
    assign byte_offset = block_offset[1:0];

    wire [2:0] current_state, next_state;
    wire fsm_hit;
    wire fsm_miss;
    wire write_enable;
    wire [1:0] update_way;

    wire tag_hit;
    wire [1:0] way;
    wire [1:0] update_lru;

    fsm_module fsm_inst (
        .clk(clk),
        .reset(reset),
        .read(read),
        .write(write),
        .hit(tag_hit),
        .miss(fsm_miss),
        .write_enable(write_enable),
        .update_way(update_way),
        .current_state(current_state),
        .next_state(next_state)
    );

    assign hit = read & tag_hit;
    assign miss = (read | write) & fsm_miss;

    tag_array tag_inst (
        .clk(clk),
        .set_index(set_index),
        .tag(tag),
        .write_enable(write_enable),
        .read(read),
        .update_way(update_way),
        .hit(tag_hit),
        .way(way)
    );

    data_array data_inst (
        .clk(clk),
        .set_index(set_index),
        .way(way),
        .block_offset(block_offset),
        .byte_offset(byte_offset),
        .write_data(write_data),
        .read_data(read_data),
        .write(write),
        .read(read)
    );

    lru_module lru_inst (
        .clk(clk),
        .set_index(set_index),
        .way(way),
        .update_lru(update_lru)
    );

endmodule




module cache_controller_tb;

    parameter CACHE_SIZE = 32 * 1024;
    parameter BLOCK_SIZE = 64;
    parameter NUM_SETS = 128;
    parameter ASSOCIATIVITY = 4;
    parameter BLOCK_OFFSET_BITS = 6;
    parameter SET_INDEX_BITS = 7;
    parameter TAG_BITS = 32 - BLOCK_OFFSET_BITS - SET_INDEX_BITS;

    reg clk;
    reg reset;
    reg read;
    reg write;
    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;
    wire hit;
    wire miss;

    cache_controller uut (
        .clk(clk),
        .reset(reset),
        .read(read),
        .write(write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .hit(hit),
        .miss(miss)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        read = 0;
        write = 0;
        address = 0;
        write_data = 0;

        #20;
        reset = 0;

        write = 1;
        address = 32'h00000000;
        write_data = 32'hAABBCCDD;
        #20;
        write = 0;

        read = 1;
        address = 32'h00000000;
        #20;
        read = 0;

        write = 1;
        address = 32'h00000040;
        write_data = 32'h11223344;
        #20;
        write = 0;

        read = 1;
        address = 32'h00000040;
        #20;
        read = 0;

        read = 1;
        address = 32'h00000000;
        #20;
        read = 0;

        write = 1;
        address = 32'h00000400; 
        write_data = 32'h55667788;
        #20;
        write = 0;

        read = 1;
        address = 32'h00000400; 
        #20;
        read = 0;

        #20; 
        $finish;
    end

    always @(*) begin
        if (hit || miss) begin
            $display("At time %t, read = %b, write = %b, address = %h, write_data = %h, read_data = %h, hit = %b, miss = %b",
                     $time, read, write, address, write_data, read_data, hit, miss);
        end
    end

endmodule



