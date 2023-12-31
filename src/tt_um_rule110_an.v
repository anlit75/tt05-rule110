`default_nettype none

module tt_um_rule110_an(
  	input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output reg  [7:0] uo_out,   // Dedicated outputs - connected to the 7 output pin
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output reg  [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
); 

    // Set all bidirectional pins as outputs
    assign uio_oe = 8'b1;

    parameter LOAD=0;	// load data
    parameter STEP=1;	// step into next generation
    parameter S0=2, S15=17;	// 16 cycles output, each cycle output 16 bits
    parameter UPDATE=18;		// update rule_in

    reg  [4:0] state, next_state;
    reg  [255:0] rule_in;
  	wire [255:0] rule_out;

    always @(posedge clk) begin
      if (!rst_n) state <= LOAD;
      else state <= next_state;
    end

    always @(*) begin
      case (state) 
        LOAD: next_state = STEP;
        STEP: next_state = S0;
        UPDATE: next_state = STEP;
        default: next_state = state + 1;
      endcase
    end

    always @(*) begin
      if (!rst_n) rule_in = 256'b0;
      else if (state == LOAD) rule_in = ui_in;
      else if (state == UPDATE) rule_in = rule_out;
      else rule_in = rule_in;
    end
    // rule_in = 256'b10001110111000100110111110001001101111100010011011111000100;

  	always @(*) begin
      if ((state >= S0 && state <= S15))
      	{uo_out, uio_out} = rule_out[16*(18-state)-1 -: 16];
    end

    rule110 rule110(
      .in(rule_in),
      .out(rule_out),
      .ena(state == STEP),
      .clk(clk),
      .rst(!rst_n)
    );
  
endmodule


module rule110(
    input  wire [255:0] in,
    output reg  [255:0] out,
    
    input  wire  ena,  
    input  wire  clk,
    input  wire  rst
); 

  	wire [255:0] left, right;

    assign left =  {1'b0, in[255:1]};
    assign right = {in[254:0], 1'b0};
        
    always @(*)
      if (ena)
      	out = (left & in & ~right) | (~left & in) | (~in & right);
endmodule
