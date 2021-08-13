// -----------------------------------------------------------------------------
// Testbench of Caesar's cipher module for debug and corner cases check
// -----------------------------------------------------------------------------
module rst_cipher_tb;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1; // dopo 12,8 nanosecondi disattivo
    -> reset_deassertion;
  end
  
  reg   [11:0][7:0]            key_char;
  reg   [7:0]             ptxt_char;
  reg                     ptxt_valid;
  reg   [15:0]            ctxt_char;
  reg                     ctxt_ready;
  reg                     err_invalid_key;
  reg                     err_key_not_installed;
  reg                     err_invalid_ptx_char;

  rst_cipher rst_cipher (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid                (ptxt_valid)
    ,.key                       (key_char)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_str                  (ctxt_char)
    //,.err_invalid_key           (err_invalid_key)
    //,.err_invalid_ptxt          (err_invalid_ptx_char)
    //,.err_key_not_installed     (err_key_not_installed)
    ,.ctxt_ready                (ctxt_ready)
  );

  reg [15:0] EXPECTED_GEN;
  reg [15:0] EXPECTED_CHECK;
  reg [15:0] EXPECTED_QUEUE[$];
  
  localparam NUL_CHAR = 8'h00;
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR     = 8'h30;
  localparam DIGIT_9_CHAR     = 8'h39;

  
  reg char_is_letter = 0; 
  reg char_is_digit = 0;
  reg [6:0][6:0][7:0] rot_table = {49{NUL_CHAR}};
  //reg [6:0][6:0][7:0] aux_table = {49{NUL_CHAR}};
  reg is_table_initialized = 0;
  
  reg err_repeated_char = 0;

  integer word_counter = 0;
  integer digit_counter = 0;
  reg [7:0] temp_row;
  reg [7:0] temp_line;

  /*task expected_ctxt(
    output [15:0] exp_char
  );
    ctxt_ready = 0;
    if(is_table_initialized && ptxt_valid)begin
      err_invalid_ptx_char = 0;
      char_is_letter = ((ptxt_char >= UPPERCASE_A_CHAR) && (ptxt_char <= UPPERCASE_Z_CHAR) ||  
                                (ptxt_char >= LOWERCASE_A_CHAR) && (ptxt_char <= LOWERCASE_Z_CHAR));
      char_is_digit = (ptxt_char >= DIGIT_0_CHAR) && (ptxt_char <= DIGIT_9_CHAR);
      err_invalid_ptx_char = !(char_is_letter || char_is_digit);

      if(!err_invalid_ptx_char)begin
        // substitution
        for (int r=1; r<7; r=r+1 ) begin
          for (int c=1; c <7; c=c+1) begin
            if( rot_table[r][c] == ptxt_char || rot_table[r][c] == (ptxt_char + 8'd32) ) begin
              exp_char[15:8]  = rot_table[r][0];
              exp_char[7:0]   = rot_table[0][c];
            end
          end
        end
        // rotation
        temp_row = rot_table[0][6];
        temp_line = rot_table[6][0];
        for (int i=6; i>=2; i=i-1 ) begin 
          rot_table[0][i] = rot_table[0][i-1];
          rot_table[i][0] = rot_table[i-1][0];
        end
        rot_table[0][1] = temp_row;
        rot_table[1][0] = temp_line;
      end else begin
        exp_char[15:8]  = NUL_CHAR;
        exp_char[7:0]   = NUL_CHAR;
      end
    end else begin
      exp_char[15:8]  = NUL_CHAR;
      exp_char[7:0]   = NUL_CHAR;
    end
  endtask
  
  
  task initialize_aux_table (
     output [6:0][6:0][7:0] rot_table
  );
    if (!is_table_initialized) begin
      //check presence of repeated or invalid characters in the key
      // (i*8)+7:i*8 = i*8 +: 8
      err_repeated_char = 0;
      err_invalid_key = 0;
      
      for(int i=0; i<12; i=i+1) begin
        char_is_letter = ((key_char[i*8 +: 8] >= UPPERCASE_A_CHAR) && (key_char[i*8 +: 8] <= UPPERCASE_Z_CHAR) ||  
                                (key_char[i*8 +: 8] >= LOWERCASE_A_CHAR) && (key_char[i*8 +: 8] <= LOWERCASE_Z_CHAR));
        char_is_digit = (key_char[i*8 +: 8] >= DIGIT_0_CHAR) && (key_char[i*8 +: 8] <= DIGIT_9_CHAR);
        err_invalid_key = err_invalid_key || !(char_is_letter || char_is_digit); 
        for(int j = 0; j< 12; j=j+1) begin
          if(i!=j) err_repeated_char = err_repeated_char || (key_char[i*8 +: 8] == key_char[j*8 +: 8]);
        end   
        if(err_repeated_char || err_invalid_key) break;
      end
      
      if(!(err_repeated_char || err_invalid_key)) begin
        is_table_initialized=1'b1;
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
      end
      
      temp_row = rot_table[0][6];
      temp_line = rot_table[6][0];

      digit_counter = 0;
      word_counter = 0;
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
  endtask
*/
  initial begin
    @(reset_deassertion);
    @(posedge clk);
    //is_table_initialized = 0;
   
    begin: TEST_KEY_NOT_INSTALLED
      $display("--> 1 %s %d ",ctxt_char, ctxt_ready);
      key_char = "abcdefghijkl";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "a";
      $display("--> 2 %s %d",ctxt_char, ctxt_ready);
      @(posedge clk);
      //key_char = "abcdefghijkl";
      //ptxt_valid = 1;
      //ptxt_char = "b";
      $display("--> 3 %s %d",ctxt_char, ctxt_ready);
      @(posedge clk);
      //ptxt_valid = 1;
      //ptxt_char = "a";
      //@(posedge clk);
      //$display("--> 4 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      //@(posedge clk);
      //$display("--> 5 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
    end: TEST_KEY_NOT_INSTALLED
    /*
    begin: TEST_WRONG_KEY
      rst_n = 0;
      @(posedge clk);
      rst_n = 1;
      key_char = "abcdefghi?kl";
      ptxt_valid = 1;
      ptxt_char = "b";
      $display("--> 1 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      @(posedge clk);
      key_char = "abcdabcdabcd";
      ptxt_valid = 1;
      ptxt_char = "a";
      $display("--> 2 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      @(posedge clk);
      key_char = "abcdefghijkl";
      ptxt_valid = 1;
      ptxt_char = "b";
      $display("--> 3 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      @(posedge clk);
      key_char = "abcdefghijkl";
      ptxt_valid = 1;
      ptxt_char = "c";
      $display("--> 4 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      @(posedge clk);
      $display("--> 5 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
      @(posedge clk);
      $display("--> 6 %s %d %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char,err_key_not_installed);
    end

    /*
    begin: TEST_INIT_TABLE
      key_char = "abcdefghijkl";
      initialize_aux_table(aux_table);
      for(int i=1; i<7; i++)begin
        $display("(%d,0) %c", i, aux_table[i][0]);
      end
      for(int j=1;j<7;j++)begin
         $display("(0,%d) %c", j, aux_table[0][j]);
      end
    end: TEST_INIT_TABLE
    */
    /*
    begin: TEST_SINGLE_SUB_ROT
      $display("START TEST %s %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char);
      key_char = "abcdefghijkl";
      ptxt_valid = 0;
      ptxt_char = NUL_CHAR;
      @(posedge clk);
      for(int i = 0; i < 26; i=i+2) begin
          ptxt_char = "a" + i;
          ptxt_valid = 1;
          @(posedge clk);
          $display("%s %d %d %d",ctxt_char, ctxt_ready, err_invalid_key, err_invalid_ptx_char);
      end
    end: TEST_SINGLE_SUB_ROT*/
    
    //reset
    //posedge
    
    /*fork

      begin: TEST_WORK
        key_char = "abcdefghijkl";
        initialize_aux_table(rot_table);
        for(int i =0; i<26; i++) begin
          ptxt_char = "a" + i;
          ptxt_valid = 1;
          @(posedge clk);
          expected_ctxt(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i =0; i<26; i++) begin
          ptxt_char = "A" + i;
          ptxt_valid = 1;
          @(posedge clk);
          expected_ctxt(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end

        for(int i=0; i<10; i++) begin
          ptxt_char = "0" + i;
          ptxt_valid = 1;
          @(posedge clk);
          expected_ctxt(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
        end
      end: TEST_WORK

      begin: CHECK_WORK
        @(posedge clk);
        EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
        for(int i = 0; i < 62; i++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          $display("loop:%d %s %s %-5s", i, ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK != ctxt_char) $stop;
        end
      end: CHECK_WORK
      
    join
*/
    $stop;
    
  end

endmodule
// -----------------------------------------------------------------------------