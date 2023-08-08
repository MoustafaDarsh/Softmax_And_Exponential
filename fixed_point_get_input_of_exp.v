module fixed_point_get_input_of_exp #(parameter
ARITH_TYPE = 1,
DATA_WIDTH = 32,
INTEGER = 16,
FRACTION = 16
) ( // INPUT/OUTPUT PORTS DECLARATION
input  wire                   clk,
input  wire                   reset,
input  wire                   softmax_enable,
input  wire [DATA_WIDTH-1:0]  in1,
input  wire [DATA_WIDTH-1:0]  in2,
input  wire [DATA_WIDTH-1:0]  in3,
input  wire [DATA_WIDTH-1:0]  in4,
input  wire [DATA_WIDTH-1:0]  max_input,

////  max(x)-x (input of exp)
output reg [DATA_WIDTH-1 : 0] max_of_10_minus_in1_reg,
output reg [DATA_WIDTH-1 : 0] max_of_10_minus_in2_reg,
output reg [DATA_WIDTH-1 : 0] max_of_10_minus_in3_reg,
output reg [DATA_WIDTH-1 : 0] max_of_10_minus_in4_reg,
output reg                    start_exp
);
/////////// INTERNAL SIGNALS
//// OUTPUTS OF n adders
wire [DATA_WIDTH-1:0] adder_1_out;
wire [DATA_WIDTH-1:0] adder_2_out;
wire [DATA_WIDTH-1:0] adder_3_out;
wire [DATA_WIDTH-1:0] adder_4_out;


//////////////////////////////////////////////////////////////////////////////

////////////// CONTROL SIGNALS which will be controlled using CONTROLLER

reg max_of_10_minus_in_en ;



/////////////////////////////////////////////////////////////////
////////// CONTROLLER OF exp_input_calculator


localparam             IDLE                        = 1'b0 ,
                       MAX_MINUS_IN_AND_EXP_START  = 1'b1 ;
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
    max_of_10_minus_in_en = 0;
    start_exp =0 ;
    //////// state transition /////
    if (softmax_enable)
        begin
    next_state = MAX_MINUS_IN_AND_EXP_START ;
        end
    else
        begin
    next_state = IDLE ;
        end
        end                    

        MAX_MINUS_IN_AND_EXP_START :
        begin
    /////// control signals/////
    max_of_10_minus_in_en =1 ;
    start_exp =1 ;
    //////// state transition /////
    next_state = IDLE ;
        end  
        default :
        begin
    /////// control signals/////
    max_of_10_minus_in_en =0 ;
    start_exp =0 ;
    //////// state transition /////
    next_state = IDLE ;
        end
        endcase
    end  






///////////// DP OF exp_input_calculator /////////////////////////////////////

////regesters needed to store   (input of exp)

/// for max_minus_in_i_reg
always @ (posedge clk or posedge reset)
begin
if (reset)
    begin
max_of_10_minus_in1_reg  <= 'b0 ;
max_of_10_minus_in2_reg  <= 'b0 ;
max_of_10_minus_in3_reg  <= 'b0 ;
max_of_10_minus_in4_reg  <= 'b0 ;
    end
else if (max_of_10_minus_in_en)
    begin
max_of_10_minus_in1_reg  <= adder_1_out ;
max_of_10_minus_in2_reg  <= adder_2_out ;
max_of_10_minus_in3_reg  <= adder_3_out ;
max_of_10_minus_in4_reg  <= adder_4_out ;
    end
else
    begin
max_of_10_minus_in1_reg  <= max_of_10_minus_in1_reg ;
max_of_10_minus_in2_reg  <= max_of_10_minus_in2_reg ;
max_of_10_minus_in3_reg  <= max_of_10_minus_in3_reg ;
max_of_10_minus_in4_reg  <= max_of_10_minus_in4_reg ;     
    end
end






















////////////////////////////////////////////////////////////////////////
/////////// Instantiations








adder #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION),
.sub(1) 
) 
adder_insta_1 (
.in1(max_input),
.in2(in1),
.out(adder_1_out)
);

adder #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION),
.sub(1) 
) 
adder_insta_2 (
.in1(max_input),
.in2(in2),
.out(adder_2_out)
);

adder #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION),
.sub(1) 
) 
adder_insta_3 (
.in1(max_input),
.in2(in3),
.out(adder_3_out)
);

adder #(
.ARITH_TYPE(ARITH_TYPE),
.DATA_WIDTH(DATA_WIDTH),
.INTEGER(INTEGER), 
.FRACTION(FRACTION),
.sub(1) 
) 
adder_insta_4 (
.in1(max_input),
.in2(in4),
.out(adder_4_out)
);



endmodule