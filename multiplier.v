module multiplier #(parameter 
                    ARITH_TYPE = 0,
	                DATA_WIDTH = 32,
	                E          = 8, 
	                M          = 23,
                    INTEGER    = 12, 
                    FRACTION   = 20) (
    input  [DATA_WIDTH-1:0] in1,
    input  [DATA_WIDTH-1:0] in2,
    output [DATA_WIDTH-1:0] out
);
    
generate
    if (ARITH_TYPE)
        fixed_point_mul  #(.DATA_WIDTH(DATA_WIDTH), .INTEGER(INTEGER), .FRACTION(FRACTION))  mul (.in1(in1), .in2(in2), .out(out));
    else
        floating_point_mul  #(.DATA_WIDTH(DATA_WIDTH), .E(E), .M(M)) mul (.in1(in1), .in2(in2), .out(out));
endgenerate

endmodule