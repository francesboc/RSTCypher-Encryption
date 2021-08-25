/*
PROJECT: Rotary Substitution Table cipher (Encryption module)

TEAM MEMBERS:
  -Francesco Bocchi
  -Luca Canuzzi
  -Davide Cossari

*/

//main module
module rst_cipher(
   input clk
  ,input rst_n
  ,input [11:0][7:0] key
  ,input ptxt_valid
  ,input [7:0] ptxt_char
  ,output reg [15:0] ctxt_str
  ,output reg ctxt_ready
  ,output reg err_invalid_ptxt_char
  ,output reg err_invalid_key
  ,output reg key_not_installed
);

  localparam NUL_CHAR = 8'h00;

  wire [11:0][7:0] rot_table;
  wire key_valid;
  wire is_key_installed;
  wire err_invalid_ptxt_char_wire;

  // store the value that tells if the plaintext is valid
  reg ptxt_valid_reg;
  // store plaintext character
  reg [7:0] ptxt_char_reg;
  // store the input key
  reg [11:0][7:0] key_reg;

  // store the value that tells if the ciphertext is ready
  reg ctxt_ready_reg;
  // store the ciphertext
  reg [15:0] ctxt_str_reg;

  always @ (posedge clk or negedge rst_n)
    if(!rst_n) begin
      ctxt_str <= {2{NUL_CHAR}};
      ctxt_ready <= 0;
      err_invalid_ptxt_char <= 0;
      err_invalid_key <= 0;
      key_not_installed <= 0;
    end else begin
      ptxt_valid_reg <= ptxt_valid;
      ptxt_char_reg <= ptxt_char;
      key_reg <= key;
      ctxt_str <= ctxt_str_reg;
      ctxt_ready <= ctxt_ready_reg;
      err_invalid_key <= !key_valid;
      key_not_installed <= !is_key_installed;
      err_invalid_ptxt_char <= err_invalid_ptxt_char_wire;
    end

  //checking if key contains repeated or invalid characters
  check_key check(
    .c0(key_reg[0]),
    .c1(key_reg[1]),
    .c2(key_reg[2]),
    .c3(key_reg[3]),
    .c4(key_reg[4]),
    .c5(key_reg[5]),
    .c6(key_reg[6]),
    .c7(key_reg[7]),
    .c8(key_reg[8]),
    .c9(key_reg[9]),
    .c10(key_reg[10]),
    .c11(key_reg[11]),
    .is_valid(key_valid)
  );

  //module that initialize, store and rotate the table
  rot_table ROT_TABLE(
    .clk(clk),
    .rst_n(rst_n),
    .key_valid(key_valid),
    .ctxt_valid(ctxt_ready_reg), //feedback wire to sublaw module
    .key(key_reg),
    .rot_table(rot_table),
    .is_table_initialized(is_key_installed)
  );

  //assign key_not_installed = !is_key_installed;

  //module that makes the plaintext substitution
  substitution_law SUB_LAW(
    .ptxt_char(ptxt_char_reg),
    .ptxt_valid(ptxt_valid_reg),
    .rot_table(rot_table),
    .is_key_installed(is_key_installed),
    .ctxt_str(ctxt_str_reg),
    .ctxt_valid(ctxt_ready_reg),
    .err_invalid_ptxt_char(err_invalid_ptxt_char_wire)
  );

endmodule

module rot_table (
   input clk
  ,input rst_n
  ,input key_valid
  ,input ctxt_valid
  ,input [11:0][7:0] key
  ,output reg [11:0][7:0] rot_table
  ,output reg is_table_initialized
);
  //temp registers for substitution
  reg [7:0] temp_row;
  reg [7:0] temp_column;

  always @ (posedge clk or negedge rst_n) 
    if(!rst_n) begin
      rot_table <= {12{8'd0}};
      temp_row <= 8'd0;
      temp_column <= 8'd0;
      is_table_initialized <= 0;
    end else if(key_valid && !is_table_initialized) begin
      /* perform "initialization" */
      // rows
      rot_table[0] <= key[11];
      rot_table[1] <= key[1];
      rot_table[2] <= key[9];
      rot_table[3] <= key[3];
      rot_table[4] <= key[7];
      rot_table[5] <= key[5];
      // columns
      rot_table[6] <= key[10];
      rot_table[7] <= key[0]; 
      rot_table[8] <= key[8]; 
      rot_table[9] <= key[2]; 
      rot_table[10] <= key[6]; 
      rot_table[11] <= key[4];

      temp_row <= key[5];
      temp_column <= key[4];
      is_table_initialized <= 1;
      //if substitution is successful, table is rotated 
    end else if(ctxt_valid) begin
      /* perform rotation */
		  // rows
      rot_table[0] <= temp_row;
      rot_table[1] <= rot_table[0];
      rot_table[2] <= rot_table[1];
      rot_table[3] <= rot_table[2];
      rot_table[4] <= rot_table[3];
      rot_table[5] <= rot_table[4];
      // columns
      rot_table[6] <=  temp_column;
      rot_table[7] <=  rot_table[6]; 
      rot_table[8] <=  rot_table[7]; 
      rot_table[9] <=  rot_table[8]; 
      rot_table[10] <= rot_table[9]; 
      rot_table[11] <= rot_table[10];
      
      temp_row <= rot_table[4];
      temp_column <= rot_table[10];
    end
endmodule

// Check if key is valid
module check_key (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,is_valid);
  input [7:0] c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11;

  output is_valid;
  wire check_all,check0,check1,check2,check3,check4,check5,check6,check7,check8,check9,check10,check11;

  localparam NUL_CHAR = 8'h00;
    
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR = 8'h30;
  localparam DIGIT_9_CHAR = 8'h39;
    
  wire       	c0_char_is_uppercase_letter;
  wire       	c0_char_is_lowercase_letter;
  wire 		  	c0_char_is_digit;
  wire       	c0_char_is_valid;
  wire       	c1_char_is_uppercase_letter;
  wire       	c1_char_is_lowercase_letter;
  wire 		  	c1_char_is_digit;
  wire       	c1_char_is_valid;
  wire       	c2_char_is_uppercase_letter;
  wire       	c2_char_is_lowercase_letter;
  wire 		  	c2_char_is_digit;
  wire       	c2_char_is_valid;
  wire       	c3_char_is_uppercase_letter;
  wire       	c3_char_is_lowercase_letter;
  wire 		  	c3_char_is_digit;
  wire       	c3_char_is_valid;
  wire       	c4_char_is_uppercase_letter;
  wire       	c4_char_is_lowercase_letter;
  wire 		  	c4_char_is_digit;
  wire       	c4_char_is_valid;
  wire       	c5_char_is_uppercase_letter;
  wire       	c5_char_is_lowercase_letter;
  wire 		  	c5_char_is_digit;
  wire       	c5_char_is_valid;
  wire       	c6_char_is_uppercase_letter;
  wire       	c6_char_is_lowercase_letter;
  wire 		  	c6_char_is_digit;
  wire       	c6_char_is_valid;
  wire       	c7_char_is_uppercase_letter;
  wire       	c7_char_is_lowercase_letter;
  wire 		  	c7_char_is_digit;
  wire       	c7_char_is_valid;
  wire       	c8_char_is_uppercase_letter;
  wire       	c8_char_is_lowercase_letter;
  wire 		  	c8_char_is_digit;
  wire       	c8_char_is_valid;
  wire       	c9_char_is_uppercase_letter;
  wire       	c9_char_is_lowercase_letter;
  wire 		  	c9_char_is_digit;
  wire       	c9_char_is_valid;
  wire       	c10_char_is_uppercase_letter;
  wire       	c10_char_is_lowercase_letter;
  wire 		  	c10_char_is_digit;
  wire       	c10_char_is_valid;
  wire       	c11_char_is_uppercase_letter;
  wire       	c11_char_is_lowercase_letter;
  wire 		  	c11_char_is_digit;
  wire       	c11_char_is_valid;
  wire 			  keyformalvalid;
    
  assign c0_char_is_uppercase_letter = (c0 >= UPPERCASE_A_CHAR) && (c0 <= UPPERCASE_Z_CHAR);                                  
  assign c0_char_is_lowercase_letter = (c0 >= LOWERCASE_A_CHAR) && (c0 <= LOWERCASE_Z_CHAR);                                        											  
  assign c0_char_is_digit = (c0 >= DIGIT_0_CHAR) && (c0 <= DIGIT_9_CHAR);                                                                              
  assign c0_char_is_valid = c0_char_is_uppercase_letter || c0_char_is_lowercase_letter || c0_char_is_digit; 

  assign c1_char_is_uppercase_letter = (c1 >= UPPERCASE_A_CHAR) && (c1 <= UPPERCASE_Z_CHAR);                                  
  assign c1_char_is_lowercase_letter = (c1 >= LOWERCASE_A_CHAR) && (c1 <= LOWERCASE_Z_CHAR);                                        											  
  assign c1_char_is_digit = (c1 >= DIGIT_0_CHAR) && (c1 <= DIGIT_9_CHAR);                                                                              
  assign c1_char_is_valid = c1_char_is_uppercase_letter || c1_char_is_lowercase_letter || c1_char_is_digit; 

  assign c2_char_is_uppercase_letter = (c2 >= UPPERCASE_A_CHAR) && (c2 <= UPPERCASE_Z_CHAR);                                  
  assign c2_char_is_lowercase_letter = (c2 >= LOWERCASE_A_CHAR) && (c2 <= LOWERCASE_Z_CHAR);                                        											  
  assign c2_char_is_digit = (c2 >= DIGIT_0_CHAR) && (c2 <= DIGIT_9_CHAR);                                                                              
  assign c2_char_is_valid = c2_char_is_uppercase_letter || c2_char_is_lowercase_letter || c2_char_is_digit; 

  assign c3_char_is_uppercase_letter = (c3 >= UPPERCASE_A_CHAR) && (c3 <= UPPERCASE_Z_CHAR);                                  
  assign c3_char_is_lowercase_letter = (c3 >= LOWERCASE_A_CHAR) && (c3 <= LOWERCASE_Z_CHAR);                                        											  
  assign c3_char_is_digit = (c3 >= DIGIT_0_CHAR) && (c3 <= DIGIT_9_CHAR);                                                                              
  assign c3_char_is_valid = c3_char_is_uppercase_letter || c3_char_is_lowercase_letter || c3_char_is_digit; 

  assign c4_char_is_uppercase_letter = (c4 >= UPPERCASE_A_CHAR) && (c4 <= UPPERCASE_Z_CHAR);                                  
  assign c4_char_is_lowercase_letter = (c4 >= LOWERCASE_A_CHAR) && (c4 <= LOWERCASE_Z_CHAR);                                        											  
  assign c4_char_is_digit = (c4 >= DIGIT_0_CHAR) && (c4 <= DIGIT_9_CHAR);                                                                              
  assign c4_char_is_valid = c4_char_is_uppercase_letter || c4_char_is_lowercase_letter || c4_char_is_digit; 
                        
  assign c5_char_is_uppercase_letter = (c5 >= UPPERCASE_A_CHAR) && (c5 <= UPPERCASE_Z_CHAR);                                  
  assign c5_char_is_lowercase_letter = (c5 >= LOWERCASE_A_CHAR) && (c5 <= LOWERCASE_Z_CHAR);                                        											  
  assign c5_char_is_digit = (c5 >= DIGIT_0_CHAR) && (c5 <= DIGIT_9_CHAR);                                                                              
  assign c5_char_is_valid = c5_char_is_uppercase_letter || c5_char_is_lowercase_letter || c5_char_is_digit; 

  assign c6_char_is_uppercase_letter = (c6 >= UPPERCASE_A_CHAR) && (c6 <= UPPERCASE_Z_CHAR);                                  
  assign c6_char_is_lowercase_letter = (c6 >= LOWERCASE_A_CHAR) && (c6 <= LOWERCASE_Z_CHAR);                                        											  
  assign c6_char_is_digit = (c6 >= DIGIT_0_CHAR) && (c6 <= DIGIT_9_CHAR);                                                                              
  assign c6_char_is_valid = c6_char_is_uppercase_letter || c6_char_is_lowercase_letter || c6_char_is_digit; 

  assign c7_char_is_uppercase_letter = (c7 >= UPPERCASE_A_CHAR) && (c7 <= UPPERCASE_Z_CHAR);                                  
  assign c7_char_is_lowercase_letter = (c7 >= LOWERCASE_A_CHAR) && (c7 <= LOWERCASE_Z_CHAR);                                        											  
  assign c7_char_is_digit = (c7 >= DIGIT_0_CHAR) && (c7 <= DIGIT_9_CHAR);                                                                              
  assign c7_char_is_valid = c7_char_is_uppercase_letter || c7_char_is_lowercase_letter || c7_char_is_digit; 

  assign c8_char_is_uppercase_letter = (c8 >= UPPERCASE_A_CHAR) && (c8 <= UPPERCASE_Z_CHAR);                                  
  assign c8_char_is_lowercase_letter = (c8 >= LOWERCASE_A_CHAR) && (c8 <= LOWERCASE_Z_CHAR);                                        											  
  assign c8_char_is_digit = (c8 >= DIGIT_0_CHAR) && (c8 <= DIGIT_9_CHAR);                                                                              
  assign c8_char_is_valid = c8_char_is_uppercase_letter || c8_char_is_lowercase_letter || c8_char_is_digit; 

  assign c9_char_is_uppercase_letter = (c9 >= UPPERCASE_A_CHAR) && (c9 <= UPPERCASE_Z_CHAR);                                  
  assign c9_char_is_lowercase_letter = (c9 >= LOWERCASE_A_CHAR) && (c9 <= LOWERCASE_Z_CHAR);                                        											  
  assign c9_char_is_digit = (c9 >= DIGIT_0_CHAR) && (c9 <= DIGIT_9_CHAR);                                                                              
  assign c9_char_is_valid = c9_char_is_uppercase_letter || c9_char_is_lowercase_letter || c9_char_is_digit; 

  assign c10_char_is_uppercase_letter = (c10 >= UPPERCASE_A_CHAR) && (c10 <= UPPERCASE_Z_CHAR);                                  
  assign c10_char_is_lowercase_letter = (c10 >= LOWERCASE_A_CHAR) && (c10 <= LOWERCASE_Z_CHAR);                                        											  
  assign c10_char_is_digit = (c10 >= DIGIT_0_CHAR) && (c10 <= DIGIT_9_CHAR);                                                                              
  assign c10_char_is_valid = c10_char_is_uppercase_letter || c10_char_is_lowercase_letter || c10_char_is_digit; 

  assign c11_char_is_uppercase_letter = (c11 >= UPPERCASE_A_CHAR) && (c11 <= UPPERCASE_Z_CHAR);                                  
  assign c11_char_is_lowercase_letter = (c11 >= LOWERCASE_A_CHAR) && (c11 <= LOWERCASE_Z_CHAR);                                        											  
  assign c11_char_is_digit = (c11 >= DIGIT_0_CHAR) && (c11 <= DIGIT_9_CHAR);                                                                              
  assign c11_char_is_valid = c11_char_is_uppercase_letter || c11_char_is_lowercase_letter || c11_char_is_digit;
      
  assign keyformalvalid = c0_char_is_valid &&
              c1_char_is_valid && 
              c2_char_is_valid && 
              c3_char_is_valid && 
              c4_char_is_valid && 
              c5_char_is_valid && 
              c6_char_is_valid && 
              c7_char_is_valid && 
              c8_char_is_valid && 
              c9_char_is_valid && 
              c10_char_is_valid && 
              c11_char_is_valid;

  // check repeated characters
  assign check0  = (c0==c1)||(c0==c2)||(c0==c3)||(c0==c4)||(c0==c5)||(c0==c6)||(c0==c7)||(c0==c8)||(c0==c9)||(c0==c10)||(c0==c11);						
  assign check1  = (c1==c2)||(c1==c3)||(c1==c4)||(c1==c5)||(c1==c6)||(c1==c7)||(c1==c8)||(c1==c9)||(c1==c10)||(c1==c11);	
  assign check2  = (c2==c3)||(c2==c4)||(c2==c5)||(c2==c6)||(c2==c7)||(c2==c8)||(c2==c9)||(c2==c10)||(c2==c11);	
  assign check3  = (c3==c4)||(c3==c5)||(c3==c6)||(c3==c7)||(c3==c8)||(c3==c9)||(c3==c10)||(c3==c11);	
  assign check4  = (c4==c5)||(c4==c6)||(c4==c7)||(c4==c8)||(c4==c9)||(c4==c10)||(c4==c11);	
  assign check5  = (c5==c6)||(c5==c7)||(c5==c8)||(c5==c9)||(c5==c10)||(c5==c11);	
  assign check6  = (c6==c7)||(c6==c8)||(c6==c9)||(c6==c10)||(c6==c11);	
  assign check7  = (c7==c8)||(c7==c9)||(c7==c10)||(c7==c11);	
  assign check8  = (c8==c9)||(c8==c10)||(c8==c11);	
  assign check9  = (c9==c10)||(c9==c11);	
  assign check10 = (c10==c11);	

  assign check_all = check0||check1||check2||check3||check4||check5||check6||check7||check8||check9||check10;						
            
  assign is_valid = (keyformalvalid===1'b1) && (check_all===1'b0) ? 1'b1:1'b0;
endmodule

module substitution_law(
  input [7:0] ptxt_char,
  input [11:0][7:0] rot_table,
  input ptxt_valid,
  input is_key_installed,
  output reg [15:0] ctxt_str, 
  output reg ctxt_valid,
  output err_invalid_ptxt_char
);

  localparam NUL_CHAR = 8'h00;
    
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR = 8'h30;
  localparam DIGIT_9_CHAR = 8'h39;

  wire is_uppercase_char;
  wire is_lowercase_char;
  wire is_digit_char;

  //checks the validity of the plaintext
  assign is_uppercase_char =  (ptxt_char >= UPPERCASE_A_CHAR) &&
                              (ptxt_char <= UPPERCASE_Z_CHAR);

  assign is_lowercase_char =  (ptxt_char >= LOWERCASE_A_CHAR) &&
                              (ptxt_char <= LOWERCASE_Z_CHAR);

  assign is_digit_char =  (ptxt_char >= DIGIT_0_CHAR) &&
                              (ptxt_char <= DIGIT_9_CHAR);

  assign err_invalid_ptxt_char = !(is_digit_char || is_uppercase_char || is_lowercase_char);

  always @(*) begin
    ctxt_valid = 0;
    if(!err_invalid_ptxt_char && ptxt_valid && is_key_installed) begin
      ctxt_valid = 1;
      // row 15:8 column 7:0
      case(ptxt_char)
        // lowercase characters
        (8'd97) : ctxt_str = {rot_table[0],rot_table[6]}; 
        (8'd98) : ctxt_str = {rot_table[0],rot_table[7]}; 
        (8'd99) : ctxt_str = {rot_table[0],rot_table[8]}; 
        (8'd100) : ctxt_str = {rot_table[0],rot_table[9]}; 
        (8'd101) : ctxt_str = {rot_table[0],rot_table[10]}; 
        (8'd102) : ctxt_str = {rot_table[0],rot_table[11]}; 
        (8'd103) : ctxt_str = {rot_table[1],rot_table[6]}; 
        (8'd104) : ctxt_str = {rot_table[1],rot_table[7]}; 
        (8'd105) : ctxt_str = {rot_table[1],rot_table[8]}; 
        (8'd106) : ctxt_str = {rot_table[1],rot_table[9]}; 
        (8'd107) : ctxt_str = {rot_table[1],rot_table[10]}; 
        (8'd108) : ctxt_str = {rot_table[1],rot_table[11]}; 
        (8'd109) : ctxt_str = {rot_table[2],rot_table[6]}; 
        (8'd110) : ctxt_str = {rot_table[2],rot_table[7]}; 
        (8'd111) : ctxt_str = {rot_table[2],rot_table[8]}; 
        (8'd112) : ctxt_str = {rot_table[2],rot_table[9]}; 
        (8'd113) : ctxt_str = {rot_table[2],rot_table[10]}; 
        (8'd114) : ctxt_str = {rot_table[2],rot_table[11]}; 
        (8'd115) : ctxt_str = {rot_table[3],rot_table[6]}; 
        (8'd116) : ctxt_str = {rot_table[3],rot_table[7]}; 
        (8'd117) : ctxt_str = {rot_table[3],rot_table[8]}; 
        (8'd118) : ctxt_str = {rot_table[3],rot_table[9]}; 
        (8'd119) : ctxt_str = {rot_table[3],rot_table[10]}; 
        (8'd120) : ctxt_str = {rot_table[3],rot_table[11]}; 
        (8'd121) : ctxt_str = {rot_table[4],rot_table[6]}; 
        (8'd122) : ctxt_str = {rot_table[4],rot_table[7]};
        // uppercase characters 
        (8'd65) : ctxt_str = {rot_table[0],rot_table[6]}; 
        (8'd66) : ctxt_str = {rot_table[0],rot_table[7]}; 
        (8'd67) : ctxt_str = {rot_table[0],rot_table[8]}; 
        (8'd68) : ctxt_str = {rot_table[0],rot_table[9]}; 
        (8'd69) : ctxt_str = {rot_table[0],rot_table[10]}; 
        (8'd70) : ctxt_str = {rot_table[0],rot_table[11]}; 
        (8'd71) : ctxt_str = {rot_table[1],rot_table[6]}; 
        (8'd72) : ctxt_str = {rot_table[1],rot_table[7]}; 
        (8'd73) : ctxt_str = {rot_table[1],rot_table[8]}; 
        (8'd74) : ctxt_str = {rot_table[1],rot_table[9]}; 
        (8'd75) : ctxt_str = {rot_table[1],rot_table[10]}; 
        (8'd76) : ctxt_str = {rot_table[1],rot_table[11]}; 
        (8'd77) : ctxt_str = {rot_table[2],rot_table[6]}; 
        (8'd78) : ctxt_str = {rot_table[2],rot_table[7]}; 
        (8'd79) : ctxt_str = {rot_table[2],rot_table[8]}; 
        (8'd80) : ctxt_str = {rot_table[2],rot_table[9]}; 
        (8'd81) : ctxt_str = {rot_table[2],rot_table[10]}; 
        (8'd82) : ctxt_str = {rot_table[2],rot_table[11]}; 
        (8'd83) : ctxt_str = {rot_table[3],rot_table[6]}; 
        (8'd84) : ctxt_str = {rot_table[3],rot_table[7]}; 
        (8'd85) : ctxt_str = {rot_table[3],rot_table[8]}; 
        (8'd86) : ctxt_str = {rot_table[3],rot_table[9]}; 
        (8'd87) : ctxt_str = {rot_table[3],rot_table[10]}; 
        (8'd88) : ctxt_str = {rot_table[3],rot_table[11]}; 
        (8'd89) : ctxt_str = {rot_table[4],rot_table[6]}; 
        (8'd90) : ctxt_str = {rot_table[4],rot_table[7]};
        // digit characters 
        (8'd48) : ctxt_str = {rot_table[4],rot_table[8]}; 
        (8'd49) : ctxt_str = {rot_table[4],rot_table[9]}; 
        (8'd50) : ctxt_str = {rot_table[4],rot_table[10]}; 
        (8'd51) : ctxt_str = {rot_table[4],rot_table[11]}; 
        (8'd52) : ctxt_str = {rot_table[5],rot_table[6]}; 
        (8'd53) : ctxt_str = {rot_table[5],rot_table[7]}; 
        (8'd54) : ctxt_str = {rot_table[5],rot_table[8]}; 
        (8'd55) : ctxt_str = {rot_table[5],rot_table[9]}; 
        (8'd56) : ctxt_str = {rot_table[5],rot_table[10]}; 
        (8'd57) : ctxt_str = {rot_table[5],rot_table[11]};
        default: begin
          ctxt_str = {2{8'h00}};
          ctxt_valid = 0;
        end
      endcase
    end else begin
      ctxt_valid = 0;
      ctxt_str = {2{8'h00}};
    end
  end
endmodule
