module vending_machine_tb();

// Testbench signals
reg clk;
reg rst;
reg [2:0] item_select;
reg [2:0] money_input;
reg insert_money;
reg select_item;

wire [2:0] change;
wire [2:0] total_cost;
wire [2:0] balance;
wire item_dispensed;
wire need_more_money;
wire [4:0] items_selected;

// Instantiate the vending machine
vending_machine uut (
    .clk(clk),
    .rst(rst),
    .item_select(item_select),
    .money_input(money_input),
    .insert_money(insert_money),
    .select_item(select_item),
    .change(change),
    .total_cost(total_cost),
    .balance(balance),
    .item_dispensed(item_dispensed),
    .need_more_money(need_more_money),
    .items_selected(items_selected)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
// Test stimulus
initial begin
    // Initialize waveform dump
    $dumpfile("vending_machine_tb.v");
    $dumpvars(0, vending_machine_tb);
    
    // Initialize signals
    rst = 1;
    item_select = 0;
    money_input = 0;
    insert_money = 0;
    select_item = 0;
    
    // Wait 100 ns for global reset
    #100;
    rst = 0;
    
    // Test Case 1: Buy item A (cost = 1)
    $display("Test Case 1: Buying item A (cost = 1)");
    item_select = 3'b000;  // Select item A
    select_item = 1;
    #10;
    select_item = 0;
    #10;
    
    money_input = 3'b001;  // Insert 1 unit
    insert_money = 1;
    #10;
    insert_money = 0;
    #20;
    
    // Test Case 2: Buy item C (cost = 5) with insufficient funds
    $display("Test Case 2: Buying item C with insufficient funds");
    item_select = 3'b010;  // Select item C
    select_item = 1;
    #10;
    select_item = 0;
    #10;
    
    money_input = 3'b011;  // Insert 3 units
    insert_money = 1;
    #10;
    insert_money = 0;
    #10;
    
    // Add more money when needed
    money_input = 3'b010;  // Insert 2 more units
    insert_money = 1;
    #10;
    insert_money = 0;
    #20;
    
    // Test Case 3: Buy multiple items (B + D = 8) with excess payment
    $display("Test Case 3: Buying multiple items with excess payment");
    rst = 1;
    #10;
    rst = 0;
    #10;
    
    // Select item B
    item_select = 3'b001;
    select_item = 1;
    #10;
    select_item = 0;
    #10;
    
    // Select item D
    item_select = 3'b011;
    select_item = 1;
    #10;
    select_item = 0;
    #10;
    
    // Insert 10 units (should get 2 units change)
    money_input = 3'b101;
    insert_money = 1;
    #10;
    insert_money = 0;
    #10;
    money_input = 3'b101;
    insert_money = 1;
    #10;
    insert_money = 0;
    #20;
    
    // Test Case 4: Reset during transaction
    $display("Test Case 4: Testing reset during transaction");
    item_select = 3'b100;  // Select item E
    select_item = 1;
    #10;
    select_item = 0;
    #10;
    
    money_input = 3'b011;  // Insert partial payment
    insert_money = 1;
    #10;
    insert_money = 0;
    #10;
    
    rst = 1;  // Reset during transaction
    #10;
    rst = 0;
    #20;
    
    // End simulation
    $display("Simulation completed");
    #100;
    $finish;
end

// Monitor changes
always @(posedge clk) begin
    if (item_dispensed)
        $display("Time %0t: Item dispensed! Change returned: %0d", $time, change);
    if (need_more_money)
        $display("Time %0t: Please insert more money. Current balance: %0d, Required amount: %0d", 
                $time, balance, total_cost);
    if (|items_selected)
        $display("Time %0t: Items selected: %b, Total cost: %0d", $time, items_selected, total_cost);
end

endmodule
