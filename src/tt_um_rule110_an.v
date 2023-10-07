`default_nettype none

module tt_um_rule110_an(
  	input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 output pin
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
); 

  // Set all bidirectional pins as outputs
  assign uio_oe = 8'b1;
  
  // wire [15:0] data, left, right;
  // reg [15:0] q;

  // assign data = 16'b0000000000000001;  
  // assign left = {q[0], q[15:1]};
  // assign right = {q[14:0], q[15]};

  // assign {uo_out, uio_out} = q;
      
  // always @(posedge clk) begin
  //   if (!rst_n) q <= data;
  //     else q <= (left & q & ~right) | (~left & q) | (~q & right);
  // end
  
  parameter LOAD=0;	// load data
  parameter STEP=1;	// step into next generation
  parameter S0=2, S15=17;	// 16 cycles output, each cycle output 16 bits
  parameter UPDATE=18;		// update rule_in
  
  reg [4:0] state, next_state;
  reg [255:0] rule_in, rule_out;
  
  always @(posedge clk) begin
    if (!rst_n) state <= LOAD;
    else state <= next_state;
  end
  
  always @(*) begin
    case (state) 
      LOAD: next_state = STEP;
      STEP: next_state = S0;
      UPDATE: next_state = STEP;
      default: next_state = next_state + 1;
    endcase
  end
  
  always @(*) begin
    if (!rst_n) rule_in = 256'b0;
    else if (state == LOAD) rule_in = ui_in;
    else if (state == UPDATE) rule_in = rule_out;
    else rule_in = rule_in;
  end
  // rule_in = 256'b10001110111000100110111110001001101111100010011011111000100;
  
  assign {uo_out, uio_out} = (state >= S0 && state <= S15) ? rule_out[16*(18-state)-1 -: 16] : {uo_out, uio_out};
  
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
    output wire [255:0] out,
    
    input  wire  ena,  
    input  wire  clk,
    input  wire  rst
); 

    wire [255:0] left, right;

    assign left =  {1'b0, in[255:1]};
    assign right = {in[254:0], 1'b0};
        
  	assign out = ena ? (left & in & ~right) | (~left & in) | (~in & right) : out;
endmodule
