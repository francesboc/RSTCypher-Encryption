module init_table (
  input             clk,
  input             rst_n,
  input      [95:0] key_char,
  output reg [6:0][6:0][7:0]  sub_char,
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

  reg [6:0][6:0][7:0] rot_table = {49{NUL_CHAR}}; //initialization with null characters
  reg [6:0][6:0][7:0] nul_table = {49{NUL_CHAR}};

  integer word_counter = 0;
  integer digit_counter = 0;

  always @(key_char) begin
    
    //check presence of repeated or invalid characters in the key
    // (i*8)+7:i*8 = i*8 +: 8 --> needed to indexing regs
    err_repeated_char = 0;
    err_invalid_key_char = 0;
    for(int i=0; i<12; i=i+1) begin
      key_char_is_letter = ((key_char[i*8 +: 8] >= UPPERCASE_A_CHAR) && (key_char[i*8 +: 8] <= UPPERCASE_Z_CHAR) ||  
                            (key_char[i*8 +: 8] >= LOWERCASE_A_CHAR) && (key_char[i*8 +: 8] <= LOWERCASE_Z_CHAR));
      key_char_is_digit = (key_char[i*8 +: 8] >= DIGIT_0_CHAR) && (key_char[i*8 +: 8] <= DIGIT_9_CHAR);
      err_invalid_key_char = err_invalid_key_char || !(key_char_is_letter || key_char_is_digit);    
      for(int j = 0; j< 12; j=j+1) begin
        if(i!=j)
          err_repeated_char = err_repeated_char || (key_char[i*8 +: 8] == key_char[j*8 +: 8]);
      end
      if(err_repeated_char || err_invalid_key_char) break;
    end

    /* 11       10      9       8
       95:88    87:80   79:72   71:64
       7        6       5       4
       63:56    55:48   47:40   39:32
       3        2       1       0
       31:24    23:16   15:8    7:0
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