`timescale 1ps / 1ps
module softmax_tb ();
//parameter ARITH_TYPE = 0; // for floating
parameter ARITH_TYPE = 1; // for fixed
parameter DATA_WIDTH = 32;
parameter INTEGER = 10;
parameter FRACTION = 22;
parameter E = 8;
parameter M = 23;



reg                   clk_tb ;
reg                   reset_tb ;
reg                   softmax_enable_tb ;
reg  [DATA_WIDTH-1:0] in1_tb ;
reg  [DATA_WIDTH-1:0] in2_tb ;
reg  [DATA_WIDTH-1:0] in3_tb ;
reg  [DATA_WIDTH-1:0] in4_tb ;
reg  [DATA_WIDTH-1:0] max_input_tb ;
wire [DATA_WIDTH-1:0] softmax_out_1_tb ;
wire [DATA_WIDTH-1:0] softmax_out_2_tb ;
wire [DATA_WIDTH-1:0] softmax_out_3_tb ;
wire [DATA_WIDTH-1:0] softmax_out_4_tb ;
wire                  softmax_output_ready_tb ;


softmax #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH), 
.INTEGER(INTEGER) ,
.FRACTION(FRACTION) ,
.M(M),
.E(E)
) 
DUT(
.clk(clk_tb),
.reset(reset_tb),
.softmax_enable(softmax_enable_tb),
.in1(in1_tb),
.in2(in2_tb),
.in3(in3_tb),
.in4(in4_tb),
.max_input(max_input_tb),
.softmax_out_1(softmax_out_1_tb),
.softmax_out_2(softmax_out_2_tb),
.softmax_out_3(softmax_out_3_tb),
.softmax_out_4(softmax_out_4_tb),
.softmax_output_ready(softmax_output_ready_tb)
);

always #5  clk_tb = !clk_tb ;   // period = 20 ns (50 MHz)
initial begin

clk_tb = 0;
reset_tb = 1;
softmax_enable_tb = 0;
//in1_tb = 'b01000001001010100000000000000000 ; // 10.625 //floating
//in1_tb = 'b00000010101010000000000000000000 ; // 10.625 //fixed
in1_tb = 'b00000001110001000000000000000000 ; // 7.0625 //fixed
in2_tb = 'b00000010101000000000000000000000 ; // 10.5 //fixed

//in2_tb = 'b01000001000011100000000000000000 ; // 8.875 //floating
//in2_tb = 'b00000010001110000000000000000000 ; // 8.875 //fixed
//in3_tb = 'b01000001001100000000000000000000 ; // 11.000 //floating
in3_tb = 'b00000010110000000000000000000000 ; // 11.000 //fixed
in4_tb = 'b0 ; // 0 //(floating or fixed)

//max_input_tb = 'b01000001001100000000000000000000 ; // 11.000 //floating
max_input_tb = 'b00000010110000000000000000000000 ; // 11.000 //fixed

#2
reset_tb = 0 ;
#1
softmax_enable_tb = 1;
#5
softmax_enable_tb = 0;
#300
$display("%b",softmax_out_1_tb);
$display("%b",softmax_out_2_tb);
$display("%b",softmax_out_3_tb);
$display("%b",softmax_out_4_tb);


#10
$stop ;

end


endmodule