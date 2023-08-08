module floating_to_fixed_conversion #(parameter
DATA_WIDTH = 32,
M = 23,
E = 8,
bias = (2**(E-1))-1,
INTEGER = 10,
FRACTION = 22
) (
input                           clk,
input                           reset,
input  wire  [DATA_WIDTH-1:0]   floating_point_input,
input  wire                     start_floating_to_fixed_conversion,
output wire  [DATA_WIDTH-1:0]   fixed_point_output_reg,
output reg                      fixed_point_number_ready

);
//// INTERNAL SIGNALS
wire   [INTEGER-1:0]     INTEGER_RESULT ;
wire   [M-1:0]    FRACTION_RESULT_MANTISSA_BASED_positive_exponent ;
wire   [2*M:0]     FRACTION_RESULT_MANTISSA_BASED_negative_exponent ;

reg   [FRACTION-1:0]    FRACTION_RESULT ;
wire   [E-1:0]  exponent;
wire   [M-1:0]  mantissa;
wire   [M:0]    mantissa_shifted;
wire            exponent_negative;
wire [E-1:0]    absolute_of_negative_exponent ;
wire [2*M:0]     mantissa_with_one ;
reg [INTEGER-1:0] INTEGER_RESULT_reg  ;
reg [FRACTION-1:0] FRACTION_RESULT_reg  ;

//////////////////////
////CONTROL SIGNALS 
reg INTEGER_AND_FRACTION_RESULT_en ;

////////// CONTROLLER OF fixed_to_floating_converter


localparam             IDLE                               = 1'b0,
                       INTEGER_AND_FRACTION_CALCULATION   = 1'b1;

//GREY ENCODING..
                      
reg current_state, next_state;  
              
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            current_state <= IDLE;       
        else
            current_state <= next_state;
    end

    always @*
    begin 
        case(current_state)
         
        IDLE : 
        begin
    /////// control signals/////
    fixed_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    //////// state transition /////
    if (start_floating_to_fixed_conversion)
        begin
    next_state = INTEGER_AND_FRACTION_CALCULATION ;
        end
    else
        begin
    next_state = IDLE ;
        end
        end                    

        INTEGER_AND_FRACTION_CALCULATION :
        begin
    /////// control signals/////
    fixed_point_number_ready = 1;
    INTEGER_AND_FRACTION_RESULT_en = 1;
    //////// state transition /////
    next_state = IDLE ;
        end
 
        default :
        begin
    /////// control signals/////
    fixed_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    //////// state transition /////
    next_state = IDLE ;
        end
        endcase
    end  







/////DP











/// ASSIGNMENT STATEMENTS

assign exponent = floating_point_input[DATA_WIDTH-1:M] - bias;
assign mantissa = floating_point_input[M-1:0];
assign exponent_negative = exponent[E-1]==1'b1;
assign mantissa_shifted = {1'b1, mantissa} >> (M - 1 - exponent);
assign mantissa_with_one = {{M{1'b0}},1'b1,mantissa} ;
assign absolute_of_negative_exponent = ~exponent + 1'b1 ;
///INTEGER RESULT CALCULATION
assign INTEGER_RESULT = (exponent_negative) ?  'b0 :  mantissa_shifted[M:1] ;
//////
////FRACTION RESULT CALCULATION
always @ (*)
begin
if (exponent_negative)
    begin
if (absolute_of_negative_exponent > (M+1))
    begin
FRACTION_RESULT = 'b0;
    end
else
    begin
FRACTION_RESULT = FRACTION_RESULT_MANTISSA_BASED_negative_exponent [2*M:(2*M)+1-FRACTION] ;   //When 2M+1 > F
    end
    end
else
    begin
FRACTION_RESULT = FRACTION_RESULT_MANTISSA_BASED_positive_exponent [M-1:M-FRACTION] ; /// when M>F
    end

end
assign FRACTION_RESULT_MANTISSA_BASED_positive_exponent = mantissa << (exponent) ;
assign FRACTION_RESULT_MANTISSA_BASED_negative_exponent = mantissa_with_one << (M+1-absolute_of_negative_exponent) ;
  // << exponent is negative number
// MANTISSA > FRACTION
//assign FRACTION_RESULT = FRACTION_RESULT_MANTISSA_BASED [M-1:M-FRACTION] ;
//assign FRACTION_RESULT = (FRACTION>M) ?  {FRACTION_RESULT_MANTISSA_BASED , {(FRACTION-M){1'b0}}} : FRACTION_RESULT_MANTISSA_BASED [M-1:M-FRACTION] ;
//WHEN F > 2M+1
//FRACTION_RESULT = {FRACTION_RESULT_MANTISSA_BASED_negative_exponent,{(F-(2M+1)){1'b0}}}  ;   //When 2M+1 < F


assign fixed_point_output_reg = {INTEGER_RESULT_reg,FRACTION_RESULT_reg};



//ALWAYS STATEMENT



always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
INTEGER_RESULT_reg <= 'b0 ;
FRACTION_RESULT_reg <= 'b0 ;
    end 
else if (INTEGER_AND_FRACTION_RESULT_en)
    begin
INTEGER_RESULT_reg <= INTEGER_RESULT  ;
FRACTION_RESULT_reg <= FRACTION_RESULT  ; 
    end
else
    begin
INTEGER_RESULT_reg <= INTEGER_RESULT_reg  ;
FRACTION_RESULT_reg <= FRACTION_RESULT_reg  ;       
    end
end






            
endmodule
