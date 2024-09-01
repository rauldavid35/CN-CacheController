module fsm_module (
    input clk,
    input reset,
    input read,
    input write,
    input hit,
    output reg miss,
    output reg write_enable,
    output reg [1:0] update_way,
    output reg [2:0] current_state,
    output reg [2:0] next_state
);

    parameter IDLE = 3'b000;
    parameter READ_HIT = 3'b001;
    parameter READ_MISS = 3'b010;
    parameter WRITE_HIT = 3'b011;
    parameter WRITE_MISS = 3'b100;
    parameter EVICT = 3'b101;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        miss = 0;
        write_enable = 0;
        update_way = 2'b00;

        case (current_state)
            IDLE: begin
                if (read) begin
                    if (hit) begin
                        next_state = READ_HIT;
                    end else begin
                        next_state = READ_MISS;
                        miss = 1;
                    end
                end else if (write) begin
                    if (hit) begin
                        next_state = WRITE_HIT;
                    end else begin
                        next_state = WRITE_MISS;
                        miss = 1;
                    end
                end
            end
            READ_HIT: begin
                next_state = IDLE;
            end
            READ_MISS: begin
                next_state = EVICT;
                write_enable = 1;
                update_way = 2'b00;
            end
            WRITE_HIT: begin
                next_state = IDLE;
            end
            WRITE_MISS: begin
                next_state = EVICT;
                write_enable = 1;
                update_way = 2'b00;
            end
            EVICT: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule
