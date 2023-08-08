module floating_point_adder #(parameter
	           DATA_WIDTH = 32,
	           M = 23,
               E = 8)
    (
    input      [DATA_WIDTH-1:0] in1,
    input      [DATA_WIDTH-1:0] in2,
    output reg [DATA_WIDTH-1:0] out
    );

    integer i;
    wire EX1_greater_than_EX2, EX1_equal_EX2;
 
    wire sign1,sign2,signOUT;
    wire [E-1:0] Exponent1,Exponent2;
    
    wire [M:0] MantissaUnNORMALIZED1;
    wire [M:0] MantissaUnNORMALIZED2;
    
    wire [2*M+1:0] MantissaUnNORMALIZEDOut;

    wire [2*M+1:0] smaller_number_shifted;
    wire [2*M+1:0] larger_number_shifted;
    
    wire [E-1:0] Difference;
    wire [E-1:0] LargerExponent;
    wire [M:0] smaller_number;
    wire [M:0] larger_number;
    wire [7:0] shft_amt;
    wire N1_larger;
    wire ZeroIN1;
    wire ZeroIN2;


    assign sign1 = in1[DATA_WIDTH-1];
    assign sign2 = in2[DATA_WIDTH-1];
    assign Exponent1 = in1[DATA_WIDTH-2:DATA_WIDTH-E-1];
    assign Exponent2 = in2[DATA_WIDTH-2:DATA_WIDTH-E-1];
    
    assign MantissaUnNORMALIZED1 = {1'b1, in1[M-1:0]};
    assign MantissaUnNORMALIZED2 = {1'b1, in2[M-1:0]};
    
    assign EX1_greater_than_EX2 = (Exponent1 > Exponent2);
    assign EX1_equal_EX2 = (Exponent1 == Exponent2); 
    
    assign LargerExponent = EX1_greater_than_EX2 ? Exponent1 : Exponent2;

    // Determine which of A, B is larger
    assign N1_larger =    EX1_greater_than_EX2 ? 1'b1 : (EX1_equal_EX2 && (MantissaUnNORMALIZED1 > MantissaUnNORMALIZED2)) ? 1'b1 : 1'b0;
        
    assign Difference = (~EX1_greater_than_EX2) ? (Exponent2 - Exponent1) :  (Exponent1 - Exponent2);

    
    assign  smaller_number = N1_larger ? MantissaUnNORMALIZED2 : MantissaUnNORMALIZED1;
    assign  larger_number = N1_larger ? MantissaUnNORMALIZED1 : MantissaUnNORMALIZED2;

    
    assign smaller_number_shifted = {1'b0, smaller_number, 23'b0} >> Difference;
    assign larger_number_shifted = {1'b0, larger_number, 23'b0};
    

    assign MantissaUnNORMALIZEDOut = (sign1^sign2) ? larger_number_shifted - smaller_number_shifted : larger_number_shifted + smaller_number_shifted;
   
    assign shft_amt = MantissaUnNORMALIZEDOut[47] ? 8'd0  : MantissaUnNORMALIZEDOut[46] ? 8'd1  :
                      MantissaUnNORMALIZEDOut[45] ? 8'd2  : MantissaUnNORMALIZEDOut[44] ? 8'd3  :
                      MantissaUnNORMALIZEDOut[43] ? 8'd4  : MantissaUnNORMALIZEDOut[42] ? 8'd5  :
                      MantissaUnNORMALIZEDOut[41] ? 8'd6  : MantissaUnNORMALIZEDOut[40] ? 8'd7  :
                      MantissaUnNORMALIZEDOut[39] ? 8'd8  : MantissaUnNORMALIZEDOut[38] ? 8'd9  :
                      MantissaUnNORMALIZEDOut[37] ? 8'd10 : MantissaUnNORMALIZEDOut[36] ? 8'd11 :
                      MantissaUnNORMALIZEDOut[35] ? 8'd12 : MantissaUnNORMALIZEDOut[34] ? 8'd13 :
                      MantissaUnNORMALIZEDOut[33] ? 8'd14 : MantissaUnNORMALIZEDOut[32] ? 8'd15 :
                      MantissaUnNORMALIZEDOut[31] ? 8'd16 : MantissaUnNORMALIZEDOut[30] ? 8'd17 :
                      MantissaUnNORMALIZEDOut[29] ? 8'd18 : MantissaUnNORMALIZEDOut[28] ? 8'd19 :
                      MantissaUnNORMALIZEDOut[27] ? 8'd20 : MantissaUnNORMALIZEDOut[26] ? 8'd21 :
                      MantissaUnNORMALIZEDOut[25] ? 8'd22 : MantissaUnNORMALIZEDOut[24] ? 8'd23 :
                      MantissaUnNORMALIZEDOut[23] ? 8'd24 : MantissaUnNORMALIZEDOut[22] ? 8'd25 :
                      MantissaUnNORMALIZEDOut[21] ? 8'd26 : MantissaUnNORMALIZEDOut[20] ? 8'd27 :
                      MantissaUnNORMALIZEDOut[19] ? 8'd28 : MantissaUnNORMALIZEDOut[18] ? 8'd29 :
                      MantissaUnNORMALIZEDOut[17] ? 8'd30 : MantissaUnNORMALIZEDOut[16] ? 8'd31 :
                      MantissaUnNORMALIZEDOut[15] ? 8'd32 : MantissaUnNORMALIZEDOut[14] ? 8'd33 :
                      MantissaUnNORMALIZEDOut[13] ? 8'd34 : MantissaUnNORMALIZEDOut[12] ? 8'd35 :
                      MantissaUnNORMALIZEDOut[11] ? 8'd36 : MantissaUnNORMALIZEDOut[10] ? 8'd37 :
                      MantissaUnNORMALIZEDOut[9]  ? 8'd38 : MantissaUnNORMALIZEDOut[8]  ? 8'd39 :
                      MantissaUnNORMALIZEDOut[7]  ? 8'd40 : MantissaUnNORMALIZEDOut[6]  ? 8'd41 :
                      MantissaUnNORMALIZEDOut[5]  ? 8'd42 : MantissaUnNORMALIZEDOut[4]  ? 8'd43 :
                      MantissaUnNORMALIZEDOut[3]  ? 8'd44 : MantissaUnNORMALIZEDOut[2]  ? 8'd45 :
                      MantissaUnNORMALIZEDOut[1]  ? 8'd46 : MantissaUnNORMALIZEDOut[0]  ? 8'd47 :
                                                    8'd48;
                                         
                                                
    wire [3*M+1:0] OutShifted;
    wire [M-1:0] LastOut;
    assign OutShifted = {MantissaUnNORMALIZEDOut, 23'b0} << (shft_amt+1);
    assign LastOut = OutShifted [3*M+1:2*M+2];
    wire [E-1:0] LastExpOut;
    assign LastExpOut = LargerExponent - shft_amt + 8'b1;
    assign signOUT = (N1_larger)? sign1 : sign2;
    
    assign ZeroIN1 = (~|in1[DATA_WIDTH-2:0]);
    assign ZeroIN2 = (~|in2[DATA_WIDTH-2:0]);

    reg [DATA_WIDTH-1:0] out_inter;
    // handle if one input is zero
    always @(*) begin
        if (ZeroIN1 & ZeroIN2) begin
            out_inter = 'b0;
        end
        else if (ZeroIN1 & (~ZeroIN2)) begin
            out_inter = in2;
        end
        else if ((~ZeroIN1) & ZeroIN2) begin
            out_inter = in1;
        end
        else begin
            out_inter = {signOUT, LastExpOut, LastOut};
        end
    end
    // handle if one input is negegative the other
    always @(*) begin
        if ((in1[DATA_WIDTH-1] != in2[DATA_WIDTH-1]) && (in1[DATA_WIDTH-2:0] == in2[DATA_WIDTH-2:0])) begin
            out = 'b0;
        end
        else begin
            out = out_inter;
        end
    end

endmodule

