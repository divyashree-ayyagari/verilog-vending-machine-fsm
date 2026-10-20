module vending_machine(
    input wire clk,
    input wire rst,
    input wire [2:0] item_select,    // 3-bit input for item selection
    input wire [2:0] money_input,    // 3-bit input for money insertion
    input wire insert_money,         // Signal to insert money
    input wire select_item,          // Signal to select item
    output reg [2:0] change,         // Change to be returned
    output reg [2:0] total_cost,     // Total cost of selected items
    output reg [2:0] balance,        // Current balance
    output reg item_dispensed,       // Signal when item is dispensed
    output reg need_more_money,      // Signal when more money is needed
    output reg [4:0] items_selected  // Bit vector showing selected items
);

// States
localparam IDLE = 3'b000;
localparam SELECT = 3'b001;
localparam PROCESS = 3'b010;
localparam DISPENSE = 3'b011;
localparam RETURN_CHANGE = 3'b100;

// Item costs
localparam A_COST = 3'b001; // 1
localparam B_COST = 3'b010; // 2
localparam C_COST = 3'b101; // 5
localparam D_COST = 3'b110; // 6
localparam E_COST = 3'b111; // 7

reg [2:0] current_state, next_state;
reg [2:0] current_balance;
reg [2:0] item_cost;

// State register
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= IDLE;
        current_balance <= 3'b000;
        items_selected <= 5'b00000;
        total_cost <= 3'b000;
    end else begin
        current_state <= next_state;
    end
end

// Item cost lookup
always @(*) begin
    case(item_select)
        3'b000: item_cost = A_COST;
        3'b001: item_cost = B_COST;
        3'b010: item_cost = C_COST;
        3'b011: item_cost = D_COST;
        3'b100: item_cost = E_COST;
        default: item_cost = 3'b000;
    endcase
end

// Next state logic
always @(*) begin
    next_state = current_state;
    need_more_money = 0;
    item_dispensed = 0;
    change = 3'b000;
    
    case(current_state)
        IDLE: begin
            if(select_item)
                next_state = SELECT;
        end
        
        SELECT: begin
            if(item_select < 3'b101 && select_item) begin
                if(~items_selected[item_select]) begin
                    items_selected[item_select] = 1;
                    total_cost = total_cost + item_cost;
                end
                if(insert_money)
                    next_state = PROCESS;
            end
        end
        
        PROCESS: begin
            if(insert_money) begin
                current_balance = current_balance + money_input;
                if(current_balance >= total_cost)
                    next_state = DISPENSE;
                else
                    need_more_money = 1;
            end
        end
        
        DISPENSE: begin
            item_dispensed = 1;
            if(current_balance > total_cost) begin
                next_state = RETURN_CHANGE;
                change = current_balance - total_cost;
            end else begin
                next_state = IDLE;
                current_balance = 3'b000;
                items_selected = 5'b00000;
                total_cost = 3'b000;
            end
        end
        
        RETURN_CHANGE: begin
            next_state = IDLE;
            current_balance = 3'b000;
            items_selected = 5'b00000;
            total_cost = 3'b000;
        end
        
        default: next_state = IDLE;
    endcase
end

// Output balance
always @(*) begin
    balance = current_balance;
end

endmodule
