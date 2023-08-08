module adder #(parameter 
                    ARITH_TYPE = 0,
	                DATA_WIDTH = 32,
	                E          = 8, 
	                M          = 23,
                    INTEGER    = 12, 
                    FRACTION   = 20,
                    sub = 0) (
    input  [DATA_WIDTH-1:0] in1,
    input  [DATA_WIDTH-1:0] in2,
    output [DATA_WIDTH-1:0] out
);
  
generate
    case (ARITH_TYPE)
        1'b0: begin
            if (sub) begin
                floating_point_adder #(.DATA_WIDTH(DATA_WIDTH), .E(E), .M(M))
                add (.in1(in1), .in2({~in2[DATA_WIDTH-1], in2[DATA_WIDTH-2:0]}), .out(out));
            end
            else begin
                floating_point_adder #(.DATA_WIDTH(DATA_WIDTH), .E(E), .M(M)) 
                add (.in1(in1), .in2(in2), .out(out));
            end
        end
        1'b1: begin
            if (sub) begin
                fixed_point_adder #(.DATA_WIDTH(DATA_WIDTH), .INTEGER(INTEGER), .FRACTION(FRACTION)) 
                add (.in1(in1), .in2((~in2+1'b1)), .out(out));
            end
            else begin
                fixed_point_adder #(.DATA_WIDTH(DATA_WIDTH), .INTEGER(INTEGER), .FRACTION(FRACTION)) 
                add (.in1(in1), .in2(in2), .out(out));
            end
        end
    endcase      
endgenerate

endmodule