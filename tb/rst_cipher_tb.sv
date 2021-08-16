module rst_cipher_tb;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1; // dopo 12,8 nanosecondi disattivo
    -> reset_deassertion;
  end
  
  reg   [11:0][7:0]       key_char;
  reg   [7:0]             ptxt_char;
  reg                     ptxt_valid;
  reg   [15:0]            ctxt_char;
  reg                     ctxt_ready;
  reg                     err_invalid_key;
  reg                     err_key_not_installed;
  reg                     err_invalid_ptxt_char;

  rst_cipher rst_cipher (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid                (ptxt_valid)
    ,.key                       (key_char)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_str                  (ctxt_char)
    //,.err_invalid_key           (err_invalid_key)
    ,.err_invalid_ptxt_char     (err_invalid_ptx_char)
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
  //reg [6:0][6:0][7:0] rot_table = {49{NUL_CHAR}};
  //reg [6:0][6:0][7:0] aux_table = {49{NUL_CHAR}};
  reg is_table_initialized = 0;
  
  reg err_repeated_char = 0;

  integer word_counter = 0;
  integer digit_counter = 0;
  reg [7:0] temp_row;
  reg [7:0] temp_column;

  reg [11:0][7:0] rot_table = {12{NUL_CHAR}};

  task rot_table_task(
    output [11:0][7:0] rot_table 
  );

    if(!is_table_initialized) begin
        rot_table[0] = key_char[11];
        rot_table[1] = key_char[1];
        rot_table[2] = key_char[9];
        rot_table[3] = key_char[3];
        rot_table[4] = key_char[7];
        rot_table[5] = key_char[5];
        // columns
        rot_table[6] = key_char[10];
        rot_table[7] = key_char[0]; 
        rot_table[8] = key_char[8]; 
        rot_table[9] = key_char[2]; 
        rot_table[10] = key_char[6]; 
        rot_table[11] = key_char[4];

        is_table_initialized = 1;
    end else begin
        temp_row = rot_table[5];
        temp_column = rot_table[11];

        rot_table[5] = rot_table[4];
        rot_table[4] = rot_table[3];
        rot_table[3] = rot_table[2];
        rot_table[2] = rot_table[1];
        rot_table[1] = rot_table[0];
        rot_table[0] = temp_row;
        // columns
        rot_table[11] = rot_table[10];
        rot_table[10] = rot_table[9];
        rot_table[9] =  rot_table[8];
        rot_table[8] =  rot_table[7];
        rot_table[7] =  rot_table[6];
        rot_table[6] =  temp_column;
    end
  endtask

  task substitution_task(
    output [15:0] ctxt_str
  );
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
        end
      endcase

  endtask

  initial begin
    @(reset_deassertion);
    @(posedge clk);
    //is_table_initialized = 0;
   
    begin: TEST_KEY_NOT_INSTALLED
      // TEST OK
      $display("--> 1 %s %d ",ctxt_char, ctxt_ready);
      key_char = "abcdefghijkl";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "a"; //expected ab and rotation
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "-"; //no rotation
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "a"; // expected gh and rotation
      @(posedge clk);
      @(posedge clk);
      rst_n = 0;
      @(posedge clk);
      rst_n = 1;
      ptxt_valid = 1;
      ptxt_char = "-";
      @(posedge clk);
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "0";
      @(posedge clk);
      key_char = "abcde???ijkl";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "0";
      key_char = "abcdefghijkl";
    end: TEST_KEY_NOT_INSTALLED

    begin: TEST_1

      rst_n = 0;
      @(posedge clk);
      rst_n = 1;
      key_char = "abcdefghijkl";
      @(posedge clk);
      rot_table_task(rot_table);
      ptxt_valid = 1;
      ptxt_char = "A";
      substitution_task(EXPECTED_GEN);
      @(posedge clk);
      $display(" test_1: %s %s %s", ctxt_char, EXPECTED_GEN, EXPECTED_GEN === ctxt_char ? "OK" : "ERROR");
      @(posedge clk);
      rot_table_task(rot_table);
      @(posedge clk);
      @(posedge clk);


    end: TEST_1
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