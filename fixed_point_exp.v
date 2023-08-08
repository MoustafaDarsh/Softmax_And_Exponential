module fixed_point_exp #(parameter
ARITH_TYPE = 1,
DATA_WIDTH =32,
INTEGER = 10,
FRACTION = 22
)
(
input  wire                   clk,
input  wire                   reset,
input  wire                   start_exp,
input  wire [DATA_WIDTH-1:0]  x,
output reg  [DATA_WIDTH-1:0]  exp_out_reg,
output reg                    softmax_output_ready
);
/// 8 cycles are taken to perform exp function using only one adder and one multiplier
///////////INTERNAL SIGNALS
// INTERNAL SIGNALS

wire [DATA_WIDTH-FRACTION-6:0]    Sat_x; //  bN-2:bP+4
wire [3:0]                        Precise_1_x; // bP+3:bP
wire [2:0]                        Precise_2_x; // bP-1:bP-3
reg  [DATA_WIDTH-1:0]             OUT_of_Precise_1_x; // P1
reg  [DATA_WIDTH-1:0]             OUT_of_Precise_2_x; // P2
wire [DATA_WIDTH-1:0]             Imprecise_x ;  //imp_x ---> (bP-4:b0)
reg  [DATA_WIDTH-1:0]             OUT_Precise_1_multiply_Precise_2_reg ; // P1*P2_reg
reg  [DATA_WIDTH-1:0]             Squared_Imprecise_x_reg ; // imp_x^2_reg
reg  [DATA_WIDTH-1:0]             Cubed_Imprecise_x_reg ; // imp_x^3_reg
reg  [DATA_WIDTH-1:0]             minus_Imprecise_x_reg ; // minus_imp_x_reg
reg  [DATA_WIDTH-1:0]             One_minus_Imprecise_x_reg ; // (1-imp_x)_reg
reg  [DATA_WIDTH-1:0]             One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg ; // (1-imp_x+imp_x^2/x)_reg
reg  [DATA_WIDTH-1:0]             two_and_half_Cubed_Imprecise_x_reg ; // 2.5*imp_x^3_reg
reg  [DATA_WIDTH-1:0]             minus_multiplied_cubed_Imprecise_x_reg ; // -2.5x^3/16_reg
reg  [DATA_WIDTH-1:0]              OUT_of_Imprecise_x_reg ;   // (1 - imp_x + imp_x^2/2 - imp_x^3 * 2.5/16)_reg

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////// i/o signals of 1 reused multipler and adder
reg  [DATA_WIDTH-1:0]            mul_in_1;
reg  [DATA_WIDTH-1:0]            mul_in_2; 
wire [DATA_WIDTH-1:0]            mul_out;
reg  [DATA_WIDTH-1:0]            adder_in_1 ;
reg  [DATA_WIDTH-1:0]            adder_in_2 ;
wire [DATA_WIDTH-1:0]            adder_out ;
/////////////////////////////////////////////////////////////////
////////control signals used in CONTROLLER
reg [1:0] mul_in_1_sel ;
reg [1:0] mul_in_2_sel ;
reg [2:0] adder_in_1_sel;
reg [2:0] adder_in_2_sel;
reg       OUT_Precise_1_multiply_Precise_2_en;
reg       Squared_Imprecise_x_en;
reg       Cubed_Imprecise_x_en;
reg       exp_out_en;
reg       minus_Imprecise_x_en;
reg       One_minus_Imprecise_x_en;
reg       One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en;
reg       two_and_half_Cubed_Imprecise_x_en ;
reg       minus_multiplied_cubed_Imprecise_x_en ;
reg       OUT_of_Imprecise_x_en ;
reg       zero_exp_out_flag ;
////////////////////////////////////////////////////////////////////////////
///// assignment statements of signals
assign Sat_x       =   x [(DATA_WIDTH-2) : (FRACTION+4)] ;
assign Precise_1_x =   x [(FRACTION+3) : (FRACTION)]    ;
assign Precise_2_x =   x [(FRACTION-1) : (FRACTION-3)]  ;
assign Imprecise_x =   { {(DATA_WIDTH-(FRACTION-3)){1'b0}}  , x [(FRACTION-4) :0] } ;
//////////////////////////////////////////////////////////////////////////////////////////

/////// Calculating values of P1 , P2 using LUTs

/////////// NOW CREATING TWO LUTS of precise_1 and precise_2
// defining LUT_1 of first 4 bits of INTEGER (precise_1)
reg [DATA_WIDTH-1:0] LUT_1 [0:15] ;
initial
begin
$readmemb ("LUT_1.txt",LUT_1) ;    
end

// defining LUT_2 of first 3 bits of FRACTION (precise_2)
reg [DATA_WIDTH-1:0] LUT_2 [0:7] ;
initial
begin
$readmemb ("LUT_2.txt",LUT_2) ;    
end

/////////////// now we use case statement to attach values of LUTs
/// always block of LUT_1
always @ (*)
begin
case (Precise_1_x)
4'd0 : OUT_of_Precise_1_x = LUT_1 [0] ; 
4'd1 : OUT_of_Precise_1_x = LUT_1 [1] ;
4'd2 : OUT_of_Precise_1_x = LUT_1 [2] ;
4'd3 : OUT_of_Precise_1_x = LUT_1 [3] ;
4'd4 : OUT_of_Precise_1_x = LUT_1 [4] ;
4'd5 : OUT_of_Precise_1_x = LUT_1 [5] ;
4'd6 : OUT_of_Precise_1_x = LUT_1 [6] ;
4'd7 : OUT_of_Precise_1_x = LUT_1 [7] ;
4'd8 : OUT_of_Precise_1_x = LUT_1 [8] ;
4'd9 : OUT_of_Precise_1_x = LUT_1 [9] ;
4'd10: OUT_of_Precise_1_x = LUT_1 [10] ;
4'd11: OUT_of_Precise_1_x = LUT_1 [11] ;
4'd12: OUT_of_Precise_1_x = LUT_1 [12] ;
4'd13: OUT_of_Precise_1_x = LUT_1 [13] ;
4'd14: OUT_of_Precise_1_x = LUT_1 [14] ;
4'd15: OUT_of_Precise_1_x = LUT_1 [15] ;
endcase
end


/// always block of LUT_2
always @ (*)
begin
case (Precise_2_x)
4'd0 : OUT_of_Precise_2_x = LUT_2 [0] ; 
4'd1 : OUT_of_Precise_2_x = LUT_2 [1] ;
4'd2 : OUT_of_Precise_2_x = LUT_2 [2] ;
4'd3 : OUT_of_Precise_2_x = LUT_2 [3] ;
4'd4 : OUT_of_Precise_2_x = LUT_2 [4] ;
4'd5 : OUT_of_Precise_2_x = LUT_2 [5] ;
4'd6 : OUT_of_Precise_2_x = LUT_2 [6] ;
4'd7 : OUT_of_Precise_2_x = LUT_2 [7] ;
endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////// CONTROLLER OF EXP


localparam [3:0]       IDLE                                               = 4'b0000, 
                       P1_M_P2_AND_MINUS_X                                = 4'b0001,  // P1*P2 AND -x
                       X_M_X_AND_ONE_MINUS_X                              = 4'b0011,  // x*x and (1-x)
                       X_M_SQUARED_X_AND_ONE_MINUS_X_PLUS_HALF_SQUARED_X  = 4'b0010,  // x*x^2 and (1-x+x^2/2)
                       TWO_AND_HALF_CUBED_X                               = 4'b0110,  // (2.5x^3)
                       MINUS_MULTIPLIED_CUBED_X                           = 4'b0111, // (-2.5x^3/16)
                       OUT_OF_IMPRECISE_X                                 = 4'b0101,  // (1-x+x^2/2-2.5x^3/16)
                       OUT_OF_EXP_WITH_SAT                                = 4'b0100, // P1*P2*IMPRECISE_OUT
                       OUT_OF_EXP                                         = 4'b1100, // P1*P2*IMPRECISE_OUT
                       OUT_OF_SOFTMAX_READY                               = 4'b1101 ; // ready flag = 1 (O/P IS READY)
//GREY ENCODING..
                      
reg [3:0] current_state, next_state;  
              
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
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;

    //////// state transition /////
    if (start_exp && (Sat_x))
        begin
    next_state = OUT_OF_EXP_WITH_SAT ;
        end
    else if (start_exp)
        begin
    next_state = P1_M_P2_AND_MINUS_X ;
        end
    else
        begin
    next_state = IDLE ;
        end
        end                    
 
        P1_M_P2_AND_MINUS_X : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 1;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 1;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = X_M_X_AND_ONE_MINUS_X ;
        end
                
        X_M_X_AND_ONE_MINUS_X : 
        begin 
    /////// control signals/////
mul_in_1_sel = 2'd1 ;
mul_in_2_sel = 2'd1;
adder_in_1_sel =3'd1 ;
adder_in_2_sel = 3'd1;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 1;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 1;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = X_M_SQUARED_X_AND_ONE_MINUS_X_PLUS_HALF_SQUARED_X ;
        end
        
        X_M_SQUARED_X_AND_ONE_MINUS_X_PLUS_HALF_SQUARED_X :
        begin
    /////// control signals/////
mul_in_1_sel = 2'd1 ;
mul_in_2_sel = 2'd2;
adder_in_1_sel =3'd2 ;
adder_in_2_sel =3'd2;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 1;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 1;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = TWO_AND_HALF_CUBED_X;
        end
    
        TWO_AND_HALF_CUBED_X :
        begin
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel = 3'd3;
adder_in_2_sel = 3'd3;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 1;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = MINUS_MULTIPLIED_CUBED_X ;
        end  
        MINUS_MULTIPLIED_CUBED_X : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =3'd4 ;
adder_in_2_sel = 3'd4;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 1 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = OUT_OF_IMPRECISE_X ;
        end
        OUT_OF_IMPRECISE_X : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =3'd5 ;
adder_in_2_sel = 3'd5;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  1;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = OUT_OF_EXP ;
        end

        OUT_OF_EXP : 
        begin  
    /////// control signals/////
mul_in_1_sel = 2'd2 ;
mul_in_2_sel = 2'd3;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 1;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = OUT_OF_SOFTMAX_READY ;
        end
        OUT_OF_SOFTMAX_READY : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 1;
    //////// state transition /////
    next_state = IDLE ;
        end

        OUT_OF_EXP_WITH_SAT : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 1 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = OUT_OF_SOFTMAX_READY ;
        end
        default : 
        begin  
    /////// control signals/////
mul_in_1_sel = 0 ;
mul_in_2_sel = 0;
adder_in_1_sel =0 ;
adder_in_2_sel = 0;
OUT_Precise_1_multiply_Precise_2_en = 0;
Squared_Imprecise_x_en = 0;
Cubed_Imprecise_x_en = 0;
exp_out_en = 0;
minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_en = 0;
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en = 0;
two_and_half_Cubed_Imprecise_x_en  = 0;
minus_multiplied_cubed_Imprecise_x_en = 0 ;
OUT_of_Imprecise_x_en =  0;
zero_exp_out_flag = 0 ;
softmax_output_ready = 0;
    //////// state transition /////
    next_state = IDLE ;
        end
        endcase
    end  


///////////////////////////////////////////////////////////////////////




////////////////////// DP OF EXP

////// REUSING 1 MUL AND 1 ADDER USING MULTIPLEXERs which has control lines controlled by CONTROLLER
always @ (*)
begin
case (mul_in_1_sel)
2'd0:
    begin
mul_in_1 = OUT_of_Precise_1_x  ;     
    end
2'd1:
    begin
mul_in_1 = Imprecise_x ;
    end
2'd2:
    begin
mul_in_1 = OUT_Precise_1_multiply_Precise_2_reg ;
    end
2'd3:
    begin
mul_in_1 =  'b0;
    end
endcase
end

always @ (*)
begin
case (mul_in_2_sel)
2'd0:
    begin
mul_in_2 = OUT_of_Precise_2_x  ;     
    end
2'd1:
    begin
mul_in_2 = Imprecise_x ;
    end
2'd2:
    begin
mul_in_2 = Squared_Imprecise_x_reg ;
    end
2'd3:
    begin
mul_in_2 = OUT_of_Imprecise_x_reg ;   
    end

endcase


end
always @ (*)
begin
case (adder_in_1_sel)
3'd0:
    begin
adder_in_1 = ~Imprecise_x; 
    end
3'd1:
    begin
adder_in_1 = { 1'b1 ,  {FRACTION{1'b0}}}  ; // One with zero fraction of width = DATA_WIDTH
    end
3'd2:
    begin
adder_in_1 = One_minus_Imprecise_x_reg ;     
    end
3'd3:
    begin
adder_in_1 = (Cubed_Imprecise_x_reg << 1'b1) ;
    end
3'd4:
    begin
adder_in_1 = ~(two_and_half_Cubed_Imprecise_x_reg >> 3'b100);
    end
3'd5:
    begin
adder_in_1 = One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg ;   
    end
default:
    begin
adder_in_1 = 'b0;
    end


endcase



end
always @ (*)
begin
case (adder_in_2_sel)
3'd0:
    begin
adder_in_2 = 'b1; 
    end
3'd1:
    begin
adder_in_2 = minus_Imprecise_x_reg ;
    end
3'd2:
    begin
adder_in_2 = (Squared_Imprecise_x_reg >>1'b1) ;     
    end
3'd3:
    begin
adder_in_2 = (Cubed_Imprecise_x_reg >> 1'b1) ;
    end
3'd4:
    begin
adder_in_2 = 'b1;
    end
3'd5:
    begin
adder_in_2 = minus_multiplied_cubed_Imprecise_x_reg ;   
    end
default:
    begin
adder_in_2 = 'b0;
    end

endcase

end

/////////////////////////////////////////////////////////////////////////////////////
////regestering outputs of MUL which are controlled by CONTROLLER

//// MUL
always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
OUT_Precise_1_multiply_Precise_2_reg <= 'b0 ;
    end
else if (OUT_Precise_1_multiply_Precise_2_en)
    begin
OUT_Precise_1_multiply_Precise_2_reg <= mul_out ;
    end
else
    begin
OUT_Precise_1_multiply_Precise_2_reg <= OUT_Precise_1_multiply_Precise_2_reg ;
    end
end

always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
Squared_Imprecise_x_reg <= 'b0 ;
    end
else if (Squared_Imprecise_x_en)
    begin
Squared_Imprecise_x_reg <= mul_out ;
    end
else
    begin
Squared_Imprecise_x_reg <= Squared_Imprecise_x_reg ;
    end
end

always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
Cubed_Imprecise_x_reg <= 'b0 ;
    end
else if (Cubed_Imprecise_x_en)
    begin
Cubed_Imprecise_x_reg <= mul_out ;
    end
else
    begin
Cubed_Imprecise_x_reg <= Cubed_Imprecise_x_reg ;
    end
end

always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
exp_out_reg <= 'b0 ;
    end
else if (zero_exp_out_flag)
    begin
exp_out_reg <= 'b0 ;
    end
else if (exp_out_en)
    begin
exp_out_reg <= mul_out ;
    end
else
    begin
exp_out_reg <= exp_out_reg ;
    end
end
////////////////////
//////////ADDER



always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
minus_Imprecise_x_reg <= 'b0 ;
    end
else if (minus_Imprecise_x_en)
    begin
minus_Imprecise_x_reg <= adder_out ;
    end
else
    begin
minus_Imprecise_x_reg <= minus_Imprecise_x_reg ;
    end
end


always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
One_minus_Imprecise_x_reg <= 'b0 ;
    end
else if (One_minus_Imprecise_x_en)
    begin
One_minus_Imprecise_x_reg <= adder_out ;
    end
else
    begin
One_minus_Imprecise_x_reg <= One_minus_Imprecise_x_reg ;
    end
end


always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg <= 'b0 ;
    end
else if (One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_en)
    begin
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg <= adder_out ;
    end
else
    begin
One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg <= One_minus_Imprecise_x_reg_plus_half_squared_imprecise_x_reg ;
    end
end


always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
two_and_half_Cubed_Imprecise_x_reg <= 'b0 ;
    end
else if (two_and_half_Cubed_Imprecise_x_en)
    begin
two_and_half_Cubed_Imprecise_x_reg <= adder_out ;
    end
else
    begin
two_and_half_Cubed_Imprecise_x_reg <= two_and_half_Cubed_Imprecise_x_reg ;
    end
end

always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
minus_multiplied_cubed_Imprecise_x_reg <= 'b0 ;
    end
else if (minus_multiplied_cubed_Imprecise_x_en)
    begin
minus_multiplied_cubed_Imprecise_x_reg <= adder_out ;
    end
else
    begin
minus_multiplied_cubed_Imprecise_x_reg <= minus_multiplied_cubed_Imprecise_x_reg ;
    end
end


always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
OUT_of_Imprecise_x_reg <= 'b0 ;
    end
else if (OUT_of_Imprecise_x_en)
    begin
OUT_of_Imprecise_x_reg <= adder_out ;
    end
else
    begin
OUT_of_Imprecise_x_reg <= OUT_of_Imprecise_x_reg ;
    end
end

////////////////////////////////////////////////////////////////////////////////////////



//// Instantiations 


adder #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION),
.sub(0)
) 
adder_insta (
.in1(adder_in_1),
.in2(adder_in_2),
.out(adder_out)
);

fixed_point_mul #(
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION)
) 
fixed_point_mul_insta
(
.in1(mul_in_1),
.in2(mul_in_2),
.out(mul_out)
);







endmodule