`timescale 1ns / 1ps


module softmax #(parameter
	ARITH_TYPE = 1,
	DATA_WIDTH = 32,
	INTEGER = 10, 
	FRACTION = 22,
    E=8,
    M=23 )
    (
input  wire                  clk,
input  wire                  reset,
input  wire                  softmax_enable,
input  wire [DATA_WIDTH-1:0] in1,
input  wire [DATA_WIDTH-1:0] in2,
input  wire [DATA_WIDTH-1:0] in3,
input  wire [DATA_WIDTH-1:0] in4,
input  wire [DATA_WIDTH-1:0] max_input,
output wire [DATA_WIDTH-1:0] softmax_out_1,
output wire [DATA_WIDTH-1:0] softmax_out_2,
output wire [DATA_WIDTH-1:0] softmax_out_3,
output wire [DATA_WIDTH-1:0] softmax_out_4,
output wire                  softmax_output_ready
    );
    
generate
if (ARITH_TYPE)
    begin
    
fixed_point_softmax  #(	
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH) ,
.INTEGER(INTEGER) , 
.FRACTION(FRACTION)
)
fixed_point_softmax_insta (
.clk(clk),
.reset(reset),
.softmax_enable(softmax_enable),
.in1(in1),
.in2(in2),
.in3(in3),
.in4(in4),
.max_input(max_input),
.softmax_out_1(softmax_out_1),
.softmax_out_2(softmax_out_2),
.softmax_out_3(softmax_out_3),
.softmax_out_4(softmax_out_4),
.softmax_output_ready(softmax_output_ready)
);
    end
else
    begin
floating_point_softmax  #(	
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH) ,
.E(E) , 
.M(M),
.INTEGER(INTEGER),
.FRACTION(FRACTION)
)
floating_point_softmax_insta (
.clk(clk),
.reset(reset),
.softmax_enable(softmax_enable),
.in1(in1),
.in2(in2),
.in3(in3),
.in4(in4),
.max_input(max_input),
.softmax_out_1(softmax_out_1),
.softmax_out_2(softmax_out_2),
.softmax_out_3(softmax_out_3),
.softmax_out_4(softmax_out_4),
.softmax_output_ready(softmax_output_ready)
);
    end
endgenerate
    
endmodule