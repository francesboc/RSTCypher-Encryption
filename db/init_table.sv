module init_table (
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
      */
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
