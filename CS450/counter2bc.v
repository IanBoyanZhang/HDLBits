
// First draft

module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output [1:0] state
);
    // localparam SNT = 2'b00;
    // localparam WNT = 2'b01;
    // localparam WT  = 2'b10;
    // localparam ST  = 2'b11;

    reg [2:0] sel_code;
    assign sel_code = {curr_state, train_taken};
    
    reg [1:0] curr_state;
    reg [1:0] next_state;
    // reg [1:0] counter;
    // convert to one-hot state machine
    always @(posedge clk, posedge areset) begin
        if (areset) begin
            curr_state <= 2'b01;
            // next_state <= 2'b01;    // Quartus warns inferred latches
        end else if (train_valid) begin
            curr_state <= next_state;
        end
    end
            
    always @(*) begin
        case (sel_code)
            3'b000 : next_state = 2'b00;
            3'b001 : next_state = 2'b01;
            3'b010 : next_state = 2'b00;
            3'b011 : next_state = 2'b10;
            3'b100 : next_state = 2'b01;
            3'b101 : next_state = 2'b11;
            3'b110 : next_state = 2'b10;
            3'b111 : next_state = 2'b11;
            default : next_state = curr_state;
        endcase
    end
    
    assign state = curr_state;
endmodule
