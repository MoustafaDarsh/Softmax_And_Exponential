`timescale 1ns / 1ps

module 
 fixed_point_mul #(parameter
	DATA_WIDTH = 5,
	INTEGER = 3, 
	FRACTION = 2 )
    (
    input signed  [DATA_WIDTH-1:0]  in1,
    input signed  [DATA_WIDTH-1:0]  in2,
    output signed [DATA_WIDTH-1:0]  out
    );
    
	wire signed [2*DATA_WIDTH-1:0] out_signal;
	
    assign out_signal = in1 * in2;
    assign out =  {out_signal[(2*FRACTION)+INTEGER-1:2*FRACTION],out_signal[(2*FRACTION)-1:FRACTION]};
   
endmodule

