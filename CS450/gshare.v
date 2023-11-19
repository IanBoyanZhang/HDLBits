module top_module(
    input clk,
    input areset,

    input  predict_valid,
    input  [6:0] predict_pc,
    output predict_taken,
    output [6:0] predict_history,

    input train_valid,
    input train_taken,
    input train_mispredicted,
    input [6:0] train_history,
    input [6:0] train_pc
);
    localparam TABLE_LENGTH = 128;

    reg [1:0] PHT [TABLE_LENGTH - 1 : 0]; // Predict history table
    
    reg [6:0] train_index;
    assign train_index = train_history ^ train_pc;
    
    // Got rid of inferred latch for integer i in Quartus
    task gen_val (output [1:0]gen_val[TABLE_LENGTH - 1 : 0]);
    	integer i;
        for (i = 0 ; i < TABLE_LENGTH ; i = i + 1) 
            gen_val[i] = 2'b01;
    endtask

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            predict_history <= 7'b0;
            gen_val(PHT);
        end
        else begin
            if (train_valid && train_mispredicted) begin
                predict_history <= {train_history[5:0], train_taken};
            end
            else if (predict_valid) begin
                predict_history <= {predict_history[5:0], predict_taken};
            end
            
            if (train_valid) begin
                if (train_taken) begin
                    PHT[train_index] <= (PHT[train_index] == 2'b11) ? 2'b11 : (PHT[train_index] + 1);
                end
                else begin
                    PHT[train_index] <= (PHT[train_index] == 2'b00) ? 2'b00 : (PHT[train_index] - 1);
                end
            end
        end
    end
    
    // counter 2bc for providing some hysteresis 
    assign predict_taken = PHT[predict_history ^ predict_pc][1];
endmodule
