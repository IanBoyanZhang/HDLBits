
// First draft

module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output [1:0] state
);
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


// A more expressive way
module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output [1:0] state
);
    localparam SNT = 2'b00;
    localparam WNT = 2'b01;
    localparam WT  = 2'b10;
    localparam ST  = 2'b11;

    reg [2:0] sel_code;
    assign sel_code = {curr_state, train_taken};
    
    reg [1:0] curr_state;
    reg [1:0] next_state;

    // convert to one-hot state machine
    always @(posedge clk, posedge areset) begin
        if (areset) begin
            curr_state <= 2'b01;
            // next_state <= 2'b01;
        end else if (train_valid) begin
            curr_state <= next_state;
        end
    end
            
    always @(*) begin
        case (sel_code)
            {WNT,1'b0} : next_state = SNT;
            {SNT,1'b1} : next_state = WNT;
            {WNT,1'b0} : next_state = SNT;
            {WNT,1'b1} : next_state = WT;
            {WT,1'b0}  : next_state = WNT;
            {WT,1'b1}  : next_state = ST;
            {ST,1'b0}  : next_state = WT;
            {ST,1'b1}  : next_state = ST;
            default : next_state = curr_state;
        endcase
    end
    
    assign state = curr_state;
endmodule

// A concise (to write) implementation wonder what it would be synthesize to
module top_module(
    input clk,
    input areset,
    input train_valid,
    input train_taken,
    output reg [1:0] state
);
    always @(posedge clk, posedge areset) begin
        if (areset)
            state <= 2'b01;
        else if (train_valid) begin
            if (train_taken)
                state <= (state == 2'b11) ? 2'b11 : (state + 1);
            else
                state <= (state == 2'b00) ? 2'b00 : (state - 1);
        end
    end
endmodule


