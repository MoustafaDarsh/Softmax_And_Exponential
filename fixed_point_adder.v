module fixed_point_adder #(parameter DATA_WIDTH = 32,
                                     INTEGER    = 12, 
                                     FRACTION   = 20) (
    input  [DATA_WIDTH-1:0] in1,
    input  [DATA_WIDTH-1:0] in2,
    output [DATA_WIDTH-1:0] out
);

assign out = in1 + in2;
  
endmodule