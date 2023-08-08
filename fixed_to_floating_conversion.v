module fixed_to_floating_conversion #(parameter
DATA_WIDTH = 32,
M = 23,
E = 8,
bias = (2**(E-1))-1,
INTEGER = 10,
FRACTION = 22
) (
// input & output ports
input                          clk,
input                          reset,
input                          start_fixed_to_floating_conversion,
input  wire  [DATA_WIDTH-1:0]  fixed_point_input,
output reg   [DATA_WIDTH-1:0]  floating_point_output_reg,
output reg                     floating_point_number_ready
);
//INTERNAL SIGNALS
wire  [DATA_WIDTH-1:0]  floating_point_output ;
wire  [INTEGER-1:0]    int_input ;
wire  [FRACTION-1:0]   fraction_input ;
wire  [DATA_WIDTH-1:0]  INTEGER_RESULT ;
wire  [DATA_WIDTH-1:0]  FRACTION_RESULT ;
wire                 sign;
///FOR INTEGER RESULT CALCULATIONS
wire [3:0] int_shft_amt;
wire [E-1:0] int_Exponent;
reg  [M-1:0] int_Mantissa;
wire [INTEGER-1:0] int_Mantissa_reversed;
reg [DATA_WIDTH-1:0] INTEGER_RESULT_reg  ;
////FOR FRACTION RESULT CALCULATION
wire [4:0]   fraction_shft_amt;
wire [E-1:0] fraction_Exponent;
wire  [FRACTION-1:0] fraction_Mantissa_FRACTION_BASED;
wire  [M-1:0] fraction_Mantissa;
reg [DATA_WIDTH-1:0] FRACTION_RESULT_reg  ;

/////////////////////////////////////
////CONTROL SIGNALS



reg INTEGER_AND_FRACTION_RESULT_en ;
reg floating_point_output_en ;
///////////////////////////////////////////////////////////////


////////// CONTROLLER OF fixed_to_floating_converter


localparam  [1:0]      IDLE                               = 2'b00,
                       INTEGER_AND_FRACTION_CALCULATION    = 2'b01 ,
                       FLOATING_POINT_OUTPUT_CALCULATION  = 2'b11 ,
                       OUTPUT_READY                       = 2'b10 ;

//GREY ENCODING..
                      
reg [1:0] current_state, next_state;  
              
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
    floating_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    floating_point_output_en = 0;
    //////// state transition /////
    if (start_fixed_to_floating_conversion)
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
    floating_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 1;
    floating_point_output_en = 1;
    //////// state transition /////
    next_state = FLOATING_POINT_OUTPUT_CALCULATION ;
        end

        FLOATING_POINT_OUTPUT_CALCULATION :
        begin
    /////// control signals/////
    floating_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    floating_point_output_en = 1;
    //////// state transition /////
    next_state = OUTPUT_READY ;
        end
 
        OUTPUT_READY :
        begin
    /////// control signals/////
    floating_point_number_ready = 1;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    floating_point_output_en = 0;
    //////// state transition /////
    next_state = IDLE ;
        end

        default :
        begin
    /////// control signals/////
    floating_point_number_ready = 0;
    INTEGER_AND_FRACTION_RESULT_en = 0;
    floating_point_output_en = 0;
    //////// state transition /////
    next_state = IDLE ;
        end
        endcase
    end  





/////////////////DP





//INTEGER RESULT CALCULATIONS
assign int_input = fixed_point_input [DATA_WIDTH-1 : FRACTION] ;

assign int_shft_amt =
                  int_input[9]  ? 4'd9 : int_input[8]  ? 4'd8 :
                  int_input[7]  ? 4'd7 : int_input[6]  ? 4'd6 :
                  int_input[5]  ? 4'd5 : int_input[4]  ? 4'd4 :
                  int_input[3]  ? 4'd3 : int_input[2]  ? 4'd2 :
                  int_input[1]  ? 4'd1 : int_input[0]  ? 4'd0 :
                                           4'd0;

assign int_Exponent          = (int_input == {INTEGER{1'b0}}) ? int_shft_amt : int_shft_amt + bias;
assign int_Mantissa_reversed = int_input << (INTEGER - int_shft_amt);

always @(*) begin
    int_Mantissa = {int_Mantissa_reversed, {M-INTEGER{1'b0}}};
end

assign INTEGER_RESULT = {1'b0, int_Exponent, int_Mantissa};

/////////////////////

// FRACTION RESULT CALCULATIONS
assign fraction_input = fixed_point_input [FRACTION-1 : 0] ;

assign fraction_shft_amt = 
fraction_input[21]  ? 5'd1 : fraction_input[20]  ? 5'd2 :
fraction_input[19]  ? 5'd3 : fraction_input[18]  ? 5'd4 :
fraction_input[17]  ? 5'd5 : fraction_input[16]  ? 5'd6 :
fraction_input[15]  ? 5'd7 : fraction_input[14]  ? 5'd8 :
fraction_input[13]  ? 5'd9 : fraction_input[12]  ? 5'd10 :
fraction_input[11]  ? 5'd11 : fraction_input[10]  ? 5'd12 :
fraction_input[9]  ? 5'd13 : fraction_input[8]  ? 5'd14 :
fraction_input[7]  ? 5'd15 : fraction_input[6]  ? 5'd16 :
fraction_input[5]  ? 5'd17 : fraction_input[4]  ? 5'd18 :
fraction_input[3]  ? 5'd19 : fraction_input[2]  ? 5'd20 :
fraction_input[1]  ? 5'd21 : fraction_input[0]  ? 5'd22 :
5'd0;

assign fraction_Exponent = (fraction_input) ?  bias - fraction_shft_amt : 'b0 ;
assign fraction_Mantissa_FRACTION_BASED = fraction_input << fraction_shft_amt;
//assign fraction_Mantissa = (M > FRACTION) ? {fraction_Mantissa_FRACTION_BASED , {(M-FRACTION){1'b0}}} : fraction_Mantissa_FRACTION_BASED [FRACTION-1:FRACTION-M]   ;
//MANTISSA > FRACTION
assign fraction_Mantissa = {fraction_Mantissa_FRACTION_BASED , {(M-FRACTION){1'b0}}}   ;

assign FRACTION_RESULT =   {1'b0, fraction_Exponent, fraction_Mantissa};




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

always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
floating_point_output_reg <= 'b0;  
    end
else if (floating_point_output_en)
    begin
floating_point_output_reg <= floating_point_output ;
    end
else
    begin
floating_point_output_reg <= floating_point_output_reg ;
    end
end

















// FLOATING POINT ADDER (ADD INT + FRACTION PART)
adder #(
.ARITH_TYPE(0),
.DATA_WIDTH(DATA_WIDTH),
.E(E),
.M(M),
.sub(0)
) 
adder_insta
(
.in1(INTEGER_RESULT_reg),
.in2(FRACTION_RESULT_reg),
.out(floating_point_output)
);





endmodule