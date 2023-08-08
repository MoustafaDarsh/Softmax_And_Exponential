module floating_point_exp #(parameter
ARITH_TYPE = 0,
DATA_WIDTH =32,
E=8,
M=23,
INTEGER = 10,
FRACTION = 22
)
(
input  wire                   clk,
input  wire                   reset,
input  wire                   start_exp,
input  wire  [DATA_WIDTH-1:0]  x,
output wire  [DATA_WIDTH-1:0] exp_out_reg,
output wire                   softmax_output_ready
);

wire [DATA_WIDTH-1:0] x_fixed ;
wire [DATA_WIDTH-1:0] fixed_point_exp_out ;
wire fixed_point_number_ready ;
wire fixed_point_softmax_output_ready ;













// INSTANTIATIONS

floating_to_fixed_conversion #(
.DATA_WIDTH (DATA_WIDTH),
.M(M),
.E(E),
.INTEGER(INTEGER),
.FRACTION(FRACTION)
) 

floating_to_fixed_conversion_insta (
.clk(clk),
.reset(reset),
.floating_point_input(x),
.start_floating_to_fixed_conversion(start_exp),
.fixed_point_output_reg(x_fixed),
.fixed_point_number_ready(fixed_point_number_ready)
);


fixed_point_exp #(
.ARITH_TYPE(1),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER),
.FRACTION(FRACTION) 

) fixed_point_exp_insta
 (
.clk(clk),
.reset(reset),
.start_exp(fixed_point_number_ready),
.x(x_fixed),
.exp_out_reg(fixed_point_exp_out),
.softmax_output_ready(fixed_point_softmax_output_ready)
);

fixed_to_floating_conversion #(
.DATA_WIDTH (DATA_WIDTH),
.M(M),
.E(E),
.INTEGER(INTEGER),
.FRACTION(FRACTION)
) fixed_to_floating_conversion (
.clk(clk),
.reset(reset),
.start_fixed_to_floating_conversion(fixed_point_softmax_output_ready),
.fixed_point_input(fixed_point_exp_out),
.floating_point_output_reg(exp_out_reg),
.floating_point_number_ready(softmax_output_ready)
);






endmodule