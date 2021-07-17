/*

************DEPRECATOOOOOOO***********************************************
Notes:
 1) How to detect repeated char?
    -   first idea: feedback wire from output reg 'sub_char' to the input 'previous_char' and compare with key_char
        that is initialized with NULL char (8'h00) (maybe previous_char not needed)
*/

module init_table (
  input             clk,
  input             rst_n,
  input      [95:0] key_char,
  output reg [7:0]  sub_char[7][7],
  output reg           err_repeated_char, // flag to detect repeated characters
  output reg           err_invalid_key_char // flag to detect invalid characters   
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

  reg key_char_is_letter; 
  reg key_char_is_digit; 
  reg bool_1; 
  reg bool_2;

  reg [7:0] rot_table[7][7];
  reg [7:0] nul_table[7][7];

  integer word_counter = 0;
  integer digit_counter = 0;
  /*genvar i,j;
  
  // ---------------------------------------------------------------------------
  // Logic Design
  // ---------------------------------------------------------------------------
  generate
	  for(i=1; i < 12; i=i+1) begin
		if(key_char[i]===key_char[i-1])
			assign err_repeated_char = 1'b1;
		assign key_char_is_letter = ((key_char[i] >= UPPERCASE_A_CHAR) && (key_char[i] <= UPPERCASE_Z_CHAR) || 
								   (key_char[i] >= LOWERCASE_A_CHAR) && (key_char[i] <= LOWERCASE_Z_CHAR));
		assign key_char_is_digit = (key_char[i] >= DIGIT_0_CHAR) && (key_char[i] <= DIGIT_9_CHAR);
		assign err_invalid_key_char = !(key_char_is_letter || key_char_is_digit);
	  end
  endgenerate*/

  reg k,l;

  always @(key_char) begin
    
    bool_1 = 1'b0; 
    bool_1 = 1'b0; 
    for(int i=1; i < 12; i=i+1) begin 
      if(key_char[i]===key_char[i-1]) 
        bool_1 = 1'b1; 
      key_char_is_letter = ((key_char[i] >= UPPERCASE_A_CHAR) && (key_char[i] <= UPPERCASE_Z_CHAR) ||  
                              (key_char[i] >= LOWERCASE_A_CHAR) && (key_char[i] <= LOWERCASE_Z_CHAR)); 
      key_char_is_digit = (key_char[i] >= DIGIT_0_CHAR) && (key_char[i] <= DIGIT_9_CHAR); 
      if(!(key_char_is_letter || key_char_is_digit)) 
        bool_2 = 1'b1; 
    end 
 
    if(bool_1) 
      err_repeated_char = 1'b1; 
    if(bool_2) 
      err_invalid_key_char = 1'b1;
	
    /*
    95:88   11
    87:80   10
    79:72   9
    71:64   8
    63:56   7
    55:48   6
    47:40   5
    39:32   4
    31:24   3
    23:16   2
    15:8    1
    7:0     0
    */
    rot_table[0][0] = NUL_CHAR;
	
	
    if(!(err_repeated_char || err_invalid_key_char))
      //rows
      rot_table[1][0] = key_char[7:0];   // s[0] = k[0]
      rot_table[2][0] = key_char[87:80]; // s[10] = k[10]
      rot_table[3][0] = key_char[23:16]; // s[2] = k[2]
      rot_table[4][0] = key_char[71:64]; // s[8] = k[8]
      rot_table[5][0] = key_char[39:32]; // s[4] = k[4]
      rot_table[6][0] = key_char[55:48]; // s[6] = k[6]
      //columns
      rot_table[0][1] = key_char[15:8];  // s[1] = k[1]
      rot_table[0][2] = key_char[95:88]; // s[11] = k[11]
      rot_table[0][3] = key_char[31:24]; // s[3] = k[3] 
      rot_table[0][4] = key_char[79:72]; // s[9] = k[9]
      rot_table[0][5] = key_char[47:40]; // s[5] = k[5]
      rot_table[0][6] = key_char[63:56]; // s[7] = k[7]
    
	
	
	for (k = 1; k<7; k=k+1) begin
	  for (l = 1; l<7; l=l+1) begin
		if(k<=5 && l<= 2) begin
		  rot_table[k][l] = LOWERCASE_A_CHAR + word_counter;
		  word_counter = word_counter + 1;
		end else begin
		  rot_table[k][l] = DIGIT_0_CHAR + digit_counter;
		  digit_counter = digit_counter + 1;
		end
	  end
	end  
	
	for (k = 0; k<7; k=k+1) begin
	  for (l = 0; l<7; l=l+1) begin
		nul_table[k][l] = NUL_CHAR;
	
	  end
	end
	
  end

  // Table initialization
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      sub_char <= nul_table;
    else if(err_invalid_key_char || err_repeated_char)
      sub_char <= nul_table;
    else
      sub_char <= rot_table;
  end

endmodule
