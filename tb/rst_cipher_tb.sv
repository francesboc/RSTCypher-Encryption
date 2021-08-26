/*
PROJECT: Rotary Substitution Table cipher (Encryption module)

TEAM MEMBERS:
  -Francesco Bocchi
  -Luca Canuzzi
  -Davide Cossari

*/

module rst_cipher_tb;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1;
    -> reset_deassertion;
  end
  
  reg   [11:0][7:0]  key_char;
  reg   [7:0]        ptxt_char;
  reg                ptxt_valid;
  wire  [15:0]       ctxt_char;
  reg                ctxt_ready;
  reg                err_invalid_key;
  reg                err_key_not_installed;
  reg                err_invalid_ptxt_char;
  reg                key_not_installed;

  rst_cipher rst_cipher (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.ptxt_valid                (ptxt_valid)
    ,.key                       (key_char)
    ,.ptxt_char                 (ptxt_char)
    ,.ctxt_str                  (ctxt_char)
    ,.err_invalid_key           (err_invalid_key)
    ,.err_invalid_ptxt_char     (err_invalid_ptxt_char)
    ,.ctxt_ready                (ctxt_ready)
    ,.key_not_installed         (key_not_installed)
  );

  reg [15:0] EXPECTED_GEN;
  reg [15:0] EXPECTED_CHECK;
  reg [15:0] EXPECTED_QUEUE[$];
  
  reg [7:0] EXPECTED_CHAR;
  reg [7:0] EXPECTED_CHAR_QUEUE[$];

  localparam NUL_CHAR = 8'h00;
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR     = 8'h30;
  localparam DIGIT_9_CHAR     = 8'h39;

  //used in tasks
  reg char_is_letter = 0; 
  reg char_is_digit = 0;
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

    key_char = "abcdefghijkl";
    rot_table_task(rot_table);
    @(posedge clk);
    $display("Start complete workflow test.");
    fork
      begin: TEST_WORKFLOW
        for(int i = 0; i < 26; i++) begin
          ptxt_valid = 1;
          ptxt_char = "A" + i;
          substitution_task(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);
          EXPECTED_CHAR_QUEUE.push_back(ptxt_char);
          @(posedge clk);
          rot_table_task(rot_table);  
        end

        for(int i = 0; i < 26; i++) begin
          ptxt_valid = 1;
          ptxt_char = "a" + i;
          substitution_task(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);  
          EXPECTED_CHAR_QUEUE.push_back(ptxt_char);
          @(posedge clk);
          rot_table_task(rot_table);
        end

        for(int i = 0; i < 10; i++) begin
          ptxt_valid = 1;
          ptxt_char = "0" + i;
          substitution_task(EXPECTED_GEN);
          EXPECTED_QUEUE.push_back(EXPECTED_GEN);  
          EXPECTED_CHAR_QUEUE.push_back(ptxt_char);
          @(posedge clk);
          rot_table_task(rot_table);
        end
      end: TEST_WORKFLOW

      begin: TEST_WORKFLOW_CHECK
        @(posedge clk);
        for(int i = 0; i < 62; i++) begin
          @(posedge clk);
          EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
          EXPECTED_CHAR = EXPECTED_CHAR_QUEUE.pop_front();
          $display("%s %d %s %s %-5s",EXPECTED_CHAR, i, ctxt_char, EXPECTED_CHECK, EXPECTED_CHECK === ctxt_char ? "OK" : "ERROR");
          if(EXPECTED_CHECK !== ctxt_char) $stop;
        end
      end: TEST_WORKFLOW_CHECK

    join
    $display("Test complete workflow ended.");

    $display("Start PDF example test.");
    // cleaning
    @(posedge clk);
    rst_n = 0;
    is_table_initialized = 0;
    key_char = {12{NUL_CHAR}};
    ptxt_valid = 0;
    ptxt_char = NUL_CHAR;
    @(posedge clk);
    rst_n = 1;
    key_char = "ABCDEFGHIJKL";
    @(posedge clk);

    begin: HELLO_EXAMPLE
      ptxt_valid = 1;
      ptxt_char = "H";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "e";
      @(posedge clk);
      $display("ptx: H ctx: %s %s", ctxt_char, "KL" === ctxt_char ? "OK" : "ERROR");
      ptxt_valid = 1;
      ptxt_char = "l";
      @(posedge clk);
      $display("ptx: e ctx: %s %s", ctxt_char, "GJ" === ctxt_char ? "OK" : "ERROR");
      ptxt_valid = 1;
      ptxt_char = "l";
      @(posedge clk);
      $display("ptx: l ctx: %s %s", ctxt_char, "GJ" === ctxt_char ? "OK" : "ERROR");
      ptxt_valid = 1;
      ptxt_char = "o";
      @(posedge clk);
      $display("ptx: l ctx: %s %s", ctxt_char, "ED" === ctxt_char ? "OK" : "ERROR");
      @(posedge clk);
      $display("ptx: o ctx: %s %s", ctxt_char, "EF" === ctxt_char ? "OK" : "ERROR");
    end: HELLO_EXAMPLE
    $display("Test PDF example ended.");

    $display("Start corner case test.");
    // cleaning
    @(posedge clk);
    rst_n = 0;
    is_table_initialized = 0;
    key_char = {12{NUL_CHAR}};
    ptxt_valid = 0;
    ptxt_char = NUL_CHAR;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    begin: TEST_ERROR
      key_char = "ABC?*-.HIJKL";
      $display("Testing wrong key %s",key_char);
      @(posedge clk);
      $display("err_invalid_key: %d %s", err_invalid_key, 1 === err_invalid_key ? "OK" : "ERROR");
      key_char = "ABCDEFGHDDKL";
      $display("Testing repeated characters in key %s",key_char);
      @(posedge clk);
      $display("err_invalid_key: %d %s", err_invalid_key, 1 === err_invalid_key ? "OK" : "ERROR");
      $display("Testing encryption when key is not installed.");
      ptxt_valid = 1;
      ptxt_char = "3";
      @(posedge clk);
      @(posedge clk);
      $display("key_not_installed: %d ptx: %c ptx_valid: %d ctx: %s ctx_ready: %d %s", key_not_installed,ptxt_char,ptxt_valid, ctxt_char, ctxt_ready, 0 === ctxt_ready ? "OK" : "ERROR");
      key_char = "ABCDEFGHIJKL";
      @(posedge clk);
      $display("Testing encryption when plaintext flag is not set.");
      ptxt_valid = 0;
      ptxt_char = NUL_CHAR;
      @(posedge clk);
      @(posedge clk);
      $display("ptx_valid: %d ctx: %s ctx_ready: %d %s",ptxt_valid, ctxt_char, ctxt_ready, 0 === ctxt_ready ? "OK" : "ERROR");
      $display("Testing encryption when plaintext is not valid.");
      ptxt_valid = 1;
      ptxt_char = "*";
      @(posedge clk);
      @(posedge clk);
      $display("err_invalid_ptx: %d ptx: %c ctx: %s ctx_ready: %d %s",err_invalid_ptxt_char, ptxt_char, ctxt_char, ctxt_ready, 0 === ctxt_ready ? "OK" : "ERROR");
      $display("Testing rotation.");
      ptxt_valid = 1;
      ptxt_char = "a";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "-";
      @(posedge clk);
      $display("ptx: a ctx: %s ctx_ready: %d %s", ctxt_char, ctxt_ready, 1 === ctxt_ready ? "OK" : "ERROR");
      ptxt_valid = 1;
      ptxt_char = "b";
      @(posedge clk);
      $display("Testing rotation when plaintext is not valid. The rot table should not rotate.");
      $display("ptx: - ctx: %s ctx_ready: %d %s", ctxt_char, ctxt_ready, 0 === ctxt_ready ? "OK" : "ERROR");
      @(posedge clk);
      $display("Testing rotation after an invalid previous character. The rot table hasn't been rotated when ptx was '-'");
      $display("ptx: %c ctx: %s ctx_ready: %d %s",ptxt_char, ctxt_char, ctxt_ready, 1 === ctxt_ready ? "OK" : "ERROR");
      @(posedge clk);
    end: TEST_ERROR

    $display("Corner case test ended.");

    $display("Start test for waveforms.");
    // cleaning
    @(posedge clk);
    rst_n = 0;
    is_table_initialized = 0;
    key_char = {12{NUL_CHAR}};
    ptxt_valid = 0;
    ptxt_char = NUL_CHAR;
    @(posedge clk);
    rst_n = 1;
    key_char = "0123456789ab";
    @(posedge clk);

    begin: WAVEFORMS
      ptxt_valid = 0;
      ptxt_char = "a";
      @(posedge clk);
      ptxt_valid = 0;
      ptxt_char = "a";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "a";
      @(posedge clk);
      ptxt_valid = 0;
      ptxt_char = "a";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "b";
      @(posedge clk);
      ptxt_valid = 1;
      ptxt_char = "c";
      @(posedge clk);
      @(posedge clk);
    end: WAVEFORMS
    $display("Waveforms test ended.");
    $stop;
    
  end

endmodule
// -----------------------------------------------------------------------------