module fixed_point_softmax #(parameter
ARITH_TYPE = 1,
DATA_WIDTH = 32,
INTEGER = 16,
FRACTION = 16
)
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
// INTERNAL SIGNALS
wire [DATA_WIDTH-1:0] exp_1_input ;
wire [DATA_WIDTH-1:0] exp_2_input ;
wire [DATA_WIDTH-1:0] exp_3_input ;
wire [DATA_WIDTH-1:0] exp_4_input ;
wire                  start_exp ;



// INSTANTIATIONs

// INSTANTIATION OF MODULE WHICH CALCULATING INPUT OF EXP (INPUT- MAX OF INPUTS)
fixed_point_get_input_of_exp #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) get_input_of_exp_insta (
.clk(clk),
.reset(reset),
.softmax_enable(softmax_enable),
.in1(in1),
.in2(in2),
.in3(in3),
.in4(in4),
.max_input(max_input),
.max_of_10_minus_in1_reg(exp_1_input) ,
.max_of_10_minus_in2_reg(exp_2_input) ,
.max_of_10_minus_in3_reg(exp_3_input) ,
.max_of_10_minus_in4_reg(exp_4_input) ,
.start_exp(start_exp)
);

//////////////////////////////////////////////////////////

/// INSTANTIATION OF  n (number of inputs) MODULEs WHICH CALCULATING EXP (e^x)

fixed_point_exp #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) fixed_point_exp_1 (
.clk(clk),
.reset(reset),
.start_exp(start_exp),
.x(exp_1_input),
.exp_out_reg(softmax_out_1),
.softmax_output_ready(softmax_output_ready)
);

fixed_point_exp #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) fixed_point_exp_2 (
.clk(clk),
.reset(reset),
.start_exp(start_exp),
.x(exp_2_input),
.exp_out_reg(softmax_out_2),
.softmax_output_ready(softmax_output_ready)
);

fixed_point_exp #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) fixed_point_exp_3 (
.clk(clk),
.reset(reset),
.start_exp(start_exp),
.x(exp_3_input),
.exp_out_reg(softmax_out_3),
.softmax_output_ready(softmax_output_ready)
);

fixed_point_exp #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) fixed_point_exp_4 (
.clk(clk),
.reset(reset),
.start_exp(start_exp),
.x(exp_4_input),
.exp_out_reg(softmax_out_4),
.softmax_output_ready(softmax_output_ready)
);



endmodule