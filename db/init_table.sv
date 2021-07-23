module init_table (
  input             clk,
  input             rst_n,
  input      [95:0] key_char,
  input      [7:0] ptx_char,
  input            ptxt_valid,
  //output reg [6:0][6:0][7:0]  sub_char, //non restituisce più una tabella ma 2 caratteri di sostituzione
  output reg [15:0] sub_str, //restituiamo una stringa di due caratteri 
  //output reg           err_repeated_char, // flag to detect repeated characters
  output reg        err_invalid_key, // flag to detect invalid characters
  output reg        err_invalid_ptx_char, // flag to detect invalid plaintext char
  output reg           ctxt_ready
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

  reg err_repeated_char; // flag to detect repeated characters
  reg err_invalid_key_char; // flag to detect invalid characters

  reg char_is_letter; 
  reg char_is_digit;
  reg is_table_initialized = 1'b0; //initialization flag
  reg [7:0] temp_row;
  reg [7:0] temp_line;

  reg [6:0][6:0][7:0] rot_table = {49{NUL_CHAR}}; //initialization with null characters
  //reg [6:0][6:0][7:0] nul_table = {49{NUL_CHAR}}; non più necessario
  reg [15:0] nul_str = {2{NUL_CHAR}}; //2 caratteri nulli
  reg [15:0] ctx_char;

  integer word_counter = 0;
  integer digit_counter = 0;

  always @(key_char) begin
    if (!is_table_initialized) begin
      err_invalid_key = 0;
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
        if(err_repeated_char || err_invalid_key_char) begin
          err_invalid_key = 1;
          break;
        end 
      end

      /* 11       10      9       8
        95:88    87:80   79:72   71:64
        7        6       5       4
        63:56    55:48   47:40   39:32
        3        2       1       0
        31:24    23:16   15:8    7:0
      */
      
      rot_table[0][0] = NUL_CHAR;
      if(!(err_repeated_char || err_invalid_key_char)) begin
        is_table_initialized=1'b1;
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
      end
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

  always @(*) begin
    if(is_table_initialized && ptxt_valid)begin
      err_invalid_ptx_char = 0;
      char_is_letter = ((ptx_char >= UPPERCASE_A_CHAR) && (ptx_char <= UPPERCASE_Z_CHAR) ||  
                                (ptx_char >= LOWERCASE_A_CHAR) && (ptx_char <= LOWERCASE_Z_CHAR));
      char_is_digit = (ptx_char >= DIGIT_0_CHAR) && (ptx_char <= DIGIT_9_CHAR);
      err_invalid_ptx_char = !(char_is_letter || char_is_digit);

      if(!err_invalid_ptx_char)begin
        //Substituition
        for (int r=1; r<7; r=r+1 ) begin
          for (int c=1; c <7; c=c+1) begin
            if( rot_table[r][c] == ptx_char ) begin
              ctx_char[15:8] = rot_table[r][0];
              ctx_char[7:0] = rot_table[0][c];
            end
          end
        end
        //Ratation
        temp_row = rot_table[0][7];
        temp_line = rot_table[7][0];
        for (int i=7; i>=2; i=i-1 ) begin 
          rot_table[0][i] <= rot_table[0][i-1];
          rot_table[i][0] <= rot_table[i-1][0];
        end
        rot_table[0][1] <= temp_row;
        rot_table[1][0] <= temp_line;
      end

    end
    //ROT operations
  end

  // output di due caratteri alla volta
  // vanno aggiunti i controlli...
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      sub_str <= nul_str;
    else if(err_invalid_key || err_invalid_ptx_char) begin
      sub_str <= nul_str;
      ctxt_ready <= 0;
    end else begin
      sub_str <= ctx_char;
      ctxt_ready <= 1;
    end     
       
  end

endmodule
