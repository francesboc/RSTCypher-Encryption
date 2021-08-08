module rst_cipher(
   input clk
  ,input rst_n
  ,input key_valid
  ,input ptxt_valid
  ,input [0:11][7:0] key
  ,input [7:0] ptxt_char
  ,output [15:0] ctxt_str
  ,output ctxt_ready
);

  wire [11:0][7:0] rot_table;

  rot_table ROT_TABLE(
    .clk(clk),
    .rst_n(rst_n),
    .key_valid(key_valid),
    .ctxt_valid(ctxt_ready), //feedback wire
    .key(key),
    .rot_table(rot_table)
  );

  substitution_law SUB_LAW(
    .ptxt_char(ptxt_char),
    .ptxt_valid(ptxt_valid),
    .rot_table(rot_table),
    .ctxt_str(ctxt_str),
    .ctxt_valid(ctxt_ready)
  );

endmodule

module rot_table (
   input clk
  ,input rst_n
  ,input key_valid
  ,input ctxt_valid
  ,input [0:11][7:0] key  // 12 bytes ([7:0]) indexed as 0 to 11
  /* other ports (if any) ... */
  ,output reg [0:11][7:0] rot_table
);

  reg [0:11][7:0] rot_table;

  check_key check(
    .c0(key[0]),
    .c1(key[1]),
    .c2(key[2]),
    .c3(key[3]),
    .c4(key[4]),
    .c5(key[5]),
    .c6(key[6]),
    .c7(key[7]),
    .c8(key[8]),
    .c9(key[9]),
    .c10(key[10]),
    .c11(key[11]),
    .is_valid(key_valid)
  );

  always @ (posedge clk or negedge rst_n) 
    if(!rst_n)
      rot_table <= {12{8'd0}};
    else if(key_valid) begin
       /* perform "initialization" */
       // rows
       rot_table[0] <= key[0];
       rot_table[1] <= key[10];
       rot_table[2] <= key[2];
       rot_table[3] <= key[8];
       rot_table[4] <= key[4];
       rot_table[5] <= key[6];
       // columns
       rot_table[6] <= key[1];
       rot_table[7] <= key[11];
       rot_table[8] <= key[3]; 
       rot_table[9] <= key[9]; 
       rot_table[10] <= key[5]; 
       rot_table[10] <= key[7];
    end
    else if(ctxt_valid) begin
      /* perform rotation */
    end
endmodule

// Check if key is valid
module check_key (c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,is_valid);
  input [7:0] c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11;

  output is_valid;
  wire check_all,check0,check1,check2,check3,check4,check5,check6,check7,check8,check9,check10,check11;
  wire  [7:0] key [11:0];

  reg   [8:0] counter; // ?

  wire notformalvalid; // ?

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

// controlli su plaintext?
module substitution_law(
  input [7:0] ptxt_char,
  input [0:11][7:0] rot_table,
  input ptxt_valid,
  output reg [15:0] ctxt_str, 
  output ctxt_valid
);

  always @(*) begin
    // row 15:8 column 7:0
    case(ptxt_char)
      ("a" || "A") : ctxt_str = {rot_table[0],rot_table[6]};
      ("b" || "B") : ctxt_str = {rot_table[0],rot_table[7]};
      ("c" || "C") : ctxt_str = {rot_table[0],rot_table[8]};
      ("d" || "D") : ctxt_str = {rot_table[0],rot_table[9]};
      ("e" || "E") : ctxt_str = {rot_table[0],rot_table[10]};
      ("f" || "F") : ctxt_str = {rot_table[0],rot_table[11]};
      ("g" || "G") : ctxt_str = {rot_table[1],rot_table[6]};
      ("h" || "H") : ctxt_str = {rot_table[1],rot_table[7]};
      ("i" || "I") : ctxt_str = {rot_table[1],rot_table[8]};
      ("j" || "J") : ctxt_str = {rot_table[1],rot_table[9]};
      ("k" || "K") : ctxt_str = {rot_table[1],rot_table[10]};
      ("l" || "L") : ctxt_str = {rot_table[1],rot_table[11]};
      ("m" || "M") : ctxt_str = {rot_table[2],rot_table[6]};
      ("n" || "N") : ctxt_str = {rot_table[2],rot_table[7]};
      ("o" || "O") : ctxt_str = {rot_table[2],rot_table[8]};
      ("p" || "P") : ctxt_str = {rot_table[2],rot_table[9]};
      ("q" || "Q") : ctxt_str = {rot_table[2],rot_table[10]};
      ("r" || "R") : ctxt_str = {rot_table[2],rot_table[11]};
      ("s" || "S") : ctxt_str = {rot_table[3],rot_table[6]};
      ("t" || "T") : ctxt_str = {rot_table[3],rot_table[7]};
      ("u" || "U") : ctxt_str = {rot_table[3],rot_table[8]};
      ("v" || "V") : ctxt_str = {rot_table[3],rot_table[9]};
      ("w" || "W") : ctxt_str = {rot_table[3],rot_table[10]};
      ("x" || "X") : ctxt_str = {rot_table[3],rot_table[11]};
      ("y" || "Y") : ctxt_str = {rot_table[4],rot_table[6]};
      ("z" || "Z") : ctxt_str = {rot_table[4],rot_table[7]};
      ("0" || "Q") : ctxt_str = {rot_table[4],rot_table[8]};
      ("1") : ctxt_str = {rot_table[4],rot_table[9]};
      ("2") : ctxt_str = {rot_table[4],rot_table[10]};
      ("3") : ctxt_str = {rot_table[4],rot_table[11]};
      ("4") : ctxt_str = {rot_table[5],rot_table[6]};
      ("5") : ctxt_str = {rot_table[5],rot_table[7]};
      ("6") : ctxt_str = {rot_table[5],rot_table[8]};
      ("7") : ctxt_str = {rot_table[5],rot_table[9]};
      ("8") : ctxt_str = {rot_table[5],rot_table[10]};
      ("9") : ctxt_str = {rot_table[5],rot_table[11]};
    endcase
  end
endmodule

  /*
  wire is_a_char;
  wire is_b_char;
  wire is_c_char;
  wire is_d_char;
  wire is_e_char;
  wire is_f_char;
  wire is_g_char;
  wire is_h_char;
  wire is_i_char;
  wire is_j_char;
  wire is_k_char;
  wire is_l_char;
  wire is_m_char;
  wire is_n_char;
  wire is_o_char;
  wire is_p_char;
  wire is_q_char;
  wire is_r_char;
  wire is_s_char;
  wire is_t_char;
  wire is_w_char;
  wire is_x_char;
  wire is_y_char;
  wire is_z_char;
  wire is_0_digit;
  wire is_1_digit;
  wire is_2_digit;
  wire is_3_digit;
  wire is_4_digit;
  wire is_5_digit;
  wire is_6_digit;
  wire is_7_digit;
  wire is_8_digit;
  wire is_9_digit;

  assign is_a_char = ptxt_char === "a" || ptxt_char === "A";
  assign is_b_char = ptxt_char === "b" || ptxt_char === "B";  
  assign is_c_char = ptxt_char === "c" || ptxt_char === "C";
  assign is_d_char = ptxt_char === "d" || ptxt_char === "D";
  assign is_e_char = ptxt_char === "e" || ptxt_char === "E";
  assign is_f_char = ptxt_char === "f" || ptxt_char === "F";
  assign is_g_char = ptxt_char === "g" || ptxt_char === "G";
  assign is_h_char = ptxt_char === "h" || ptxt_char === "H";
  assign is_i_char = ptxt_char === "i" || ptxt_char === "I";
  assign is_j_char = ptxt_char === "j" || ptxt_char === "J";
  assign is_k_char = ptxt_char === "k" || ptxt_char === "K";
  assign is_l_char = ptxt_char === "l" || ptxt_char === "L";
  assign is_m_char = ptxt_char === "m" || ptxt_char === "M";
  assign is_n_char = ptxt_char === "n" || ptxt_char === "N";
  assign is_o_char = ptxt_char === "o" || ptxt_char === "O";
  assign is_p_char = ptxt_char === "p" || ptxt_char === "P";
  assign is_q_char = ptxt_char === "q" || ptxt_char === "Q";
  assign is_r_char = ptxt_char === "r" || ptxt_char === "R";
  assign is_s_char = ptxt_char === "s" || ptxt_char === "S";
  assign is_t_char = ptxt_char === "t" || ptxt_char === "T";
  assign is_w_char = ptxt_char === "w" || ptxt_char === "W";
  assign is_x_char = ptxt_char === "x" || ptxt_char === "X";
  assign is_y_char = ptxt_char === "y" || ptxt_char === "Y";
  assign is_z_char = ptxt_char === "z" || ptxt_char === "Z";
  assign is_0_digit = ptxt_char === "0";
  assign is_1_digit = ptxt_char === "1";
  assign is_2_digit = ptxt_char === "2";
  assign is_3_digit = ptxt_char === "3";
  assign is_4_digit = ptxt_char === "4";
  assign is_5_digit = ptxt_char === "5";
  assign is_6_digit = ptxt_char === "6";
  assign is_7_digit = ptxt_char === "7";
  assign is_8_digit = ptxt_char === "8";
  assign is_9_digit = ptxt_char === "9";
  */
 /* 
module rst_cipher (
  input             clk,
  input             rst_n,
  input      [95:0] key_char,
  input      [7:0]  ptxt_char,
  input             ptxt_valid,
  output reg [15:0] ctxt_str, // two characters ciphertext output
  output reg        err_invalid_key, // flag to detect invalid characters
  output reg        err_invalid_ptxt, // flag to detect invalid plaintext char
  output reg        err_key_not_installed, // flag to detect invalid plaintext char
  output reg        ctxt_ready
);

  // ---------------------------------------------------------------------------
  // Variables
  // ---------------------------------------------------------------------------
  
  localparam NUL_CHAR = 8'h00;
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR     = 8'h30;
  localparam DIGIT_9_CHAR     = 8'h39;

  reg err_repeated_char = 0; // flag to detect repeated characters
  reg err_invalid_key_char = 0; // flag to detect invalid characters
  reg err_invalid_ptxt_char = 0;
  reg char_is_letter;
  reg char_is_digit;
  reg is_table_initialized = 0; //initialization flag
  reg [7:0] temp_row;
  reg [7:0] temp_line;

  reg [6:0][6:0][7:0] rot_table = {49{NUL_CHAR}}; //initialization with null characters
  reg [15:0] sub_str = {2{NUL_CHAR}};

  integer word_counter;
  integer digit_counter;

  // ---------------------------------------------------------------------------
  // Logic Design
  // ---------------------------------------------------------------------------

  //table initialization
  always @(key_char) begin
    if (!is_table_initialized) begin
      //check presence of repeated or invalid characters in the key
      // (i*8)+7:i*8 = i*8 +: 8 --> needed to indexing regs
      err_repeated_char = 0;
      err_invalid_key_char = 0;
      for(int i=0; i<12; i=i+1) begin
        char_is_letter = ((key_char[i*8 +: 8] >= UPPERCASE_A_CHAR) && (key_char[i*8 +: 8] <= UPPERCASE_Z_CHAR) ||  
                              (key_char[i*8 +: 8] >= LOWERCASE_A_CHAR) && (key_char[i*8 +: 8] <= LOWERCASE_Z_CHAR));
        char_is_digit = (key_char[i*8 +: 8] >= DIGIT_0_CHAR) && (key_char[i*8 +: 8] <= DIGIT_9_CHAR);
        err_invalid_key_char = err_invalid_key_char || !(char_is_letter || char_is_digit);    
        for(int j = 0; j< 12; j=j+1) begin
          if(i!=j)
            err_repeated_char = err_repeated_char || (key_char[i*8 +: 8] == key_char[j*8 +: 8]);
        end
        if(err_repeated_char || err_invalid_key_char)
          break;
      end
      /*11(a)    10(b)   9(c)    8(d)
        95:88    87:80   79:72   71:64
        7(e)     6(f)    5(g)    4(h)
        63:56    55:48   47:40   39:32
        3(i)     2(j)    1(k)    0(l)
        31:24    23:16   15:8    7:0
      
      //rot_table[0][0] = NUL_CHAR;
      if(!(err_repeated_char || err_invalid_key_char)) begin
        is_table_initialized=1;
        //rows
        rot_table[1][0] = key_char[95:88];   // s[0] = k[0] = a
        rot_table[2][0] = key_char[15:8]; // s[10] = k[10] = k
        rot_table[3][0] = key_char[79:72]; // s[2] = k[2] = c
        rot_table[4][0] = key_char[31:24]; // s[8] = k[8] = i
        rot_table[5][0] = key_char[63:56]; // s[4] = k[4] = e
        rot_table[6][0] = key_char[47:40]; // s[6] = k[6] = g
        //columns
        rot_table[0][1] = key_char[87:80];  // s[1] = k[1] = b
        rot_table[0][2] = key_char[7:0]; // s[11] = k[11] = l
        rot_table[0][3] = key_char[71:64]; // s[3] = k[3] = d
        rot_table[0][4] = key_char[23:16]; // s[9] = k[9] = j
        rot_table[0][5] = key_char[55:48]; // s[5] = k[5] = f
        rot_table[0][6] = key_char[39:32]; // s[7] = k[7] = h

        digit_counter = 0;
        word_counter = 0;
        //initialization with letters and digits
        for (int k = 1; k<7; k=k+1) begin
          for (int l = 1; l<7; l=l+1) begin
            if( (k>4 && l>2) || k>5 ) begin
            rot_table[k][l] = DIGIT_0_CHAR + digit_counter;
            digit_counter = digit_counter + 1;
            end else begin
              rot_table[k][l] = LOWERCASE_A_CHAR + word_counter;
              word_counter = word_counter + 1;
            end
          end
        end
      end

    end
  end

  // substitution and rotation
  always @(*) begin
    ctxt_ready = 0;
    if(is_table_initialized && ptxt_valid)begin
      //checks on plaintext
      err_invalid_ptxt_char = 0;
      char_is_letter = ((ptxt_char >= UPPERCASE_A_CHAR) && (ptxt_char <= UPPERCASE_Z_CHAR) ||  
                        (ptxt_char >= LOWERCASE_A_CHAR) && (ptxt_char <= LOWERCASE_Z_CHAR));
      char_is_digit = (ptxt_char >= DIGIT_0_CHAR) && (ptxt_char <= DIGIT_9_CHAR);
      err_invalid_ptxt_char = !(char_is_letter || char_is_digit);

      if(!err_invalid_ptxt_char)begin
        //Substituition
        for (int r=1; r<7; r=r+1 ) begin
          for (int c=1; c <7; c=c+1) begin
            if( rot_table[r][c] == ptxt_char || rot_table[r][c] == (ptxt_char + 8'd32)) begin
              sub_str[15:8] = rot_table[r][0];
              sub_str[7:0] = rot_table[0][c];
            end
          end
        end
        //Rotation
        temp_row = rot_table[0][6];
        temp_line = rot_table[6][0];
        for (int i=6; i>=2; i=i-1 ) begin 
          rot_table[0][i] = rot_table[0][i-1];
          rot_table[i][0] = rot_table[i-1][0];
        end
        rot_table[0][1] = temp_row;
        rot_table[1][0] = temp_line;
      end

    end
  end

  // Output string
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      err_invalid_key <= 0;
      err_invalid_ptxt <=0;
      ctxt_ready <= 0;
      err_key_not_installed <= 0;
      is_table_initialized = 0;
      ctxt_str <= {2{NUL_CHAR}};
    end else if(!is_table_initialized) begin
      if(err_repeated_char || err_invalid_key_char) begin
        err_invalid_key <= 1;
        err_key_not_installed <= 0;
      end else begin
        err_invalid_key <= 0;
        err_key_not_installed <= 1;
      end
      err_invalid_ptxt <= 0;
      ctxt_ready <= 0;
      ctxt_str <= {2{NUL_CHAR}};
    // invalid plaintext character
    end else if(err_invalid_ptxt_char) begin
      err_invalid_key <= 0;
      err_invalid_ptxt <= 1;
      err_key_not_installed <= 0;
      ctxt_ready <= 0;
      ctxt_str <= {2{NUL_CHAR}};
    //check this
    end else if(!ptxt_valid) begin
      err_invalid_key <= 0;
      err_invalid_ptxt <= 0;
      err_key_not_installed <= 0;
      ctxt_ready <= 0;
      ctxt_str <= {2{NUL_CHAR}};
    end else begin
      err_invalid_key <= 0;
      err_invalid_ptxt <= 0;
      err_key_not_installed <= 0;
      ctxt_ready <= 1;
      ctxt_str <= sub_str;
    end
  end

endmodule
*/