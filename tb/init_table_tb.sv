// -----------------------------------------------------------------------------
// Testbench of Caesar's cipher module for debug and corner cases check
// -----------------------------------------------------------------------------
module init_table_tb;

  reg clk = 1'b0;
  always #5 clk = !clk;
  
  reg rst_n = 1'b0;
  event reset_deassertion;
  
  initial begin
    #12.8 rst_n = 1'b1; // dopo 12,8 nanosecondi disattivo
    -> reset_deassertion;
  end
  
  reg   [95:0]            key_char;
  wire  [6:0][6:0][7:0]   sub_char;

  init_table init_table (
     .clk                       (clk)
    ,.rst_n                     (rst_n)
    ,.key_char                  (key_char)
    ,.sub_char                  (sub_char)
    ,.err_repeated_char         (/* Unconnected */)
    ,.err_invalid_key_char      (/* Unconnected */)     
  );

  reg [6:0][6:0][7:0] EXPECTED_GEN;
  reg [6:0][6:0][7:0] EXPECTED_CHECK;
  reg [6:0][6:0][7:0] EXPECTED_QUEUE[$];
  
  localparam NUL_CHAR = 8'h00;
  
  localparam UPPERCASE_A_CHAR = 8'h41;
  localparam UPPERCASE_Z_CHAR = 8'h5A;
  localparam LOWERCASE_A_CHAR = 8'h61;
  localparam LOWERCASE_Z_CHAR = 8'h7A;
  localparam DIGIT_0_CHAR     = 8'h30;
  localparam DIGIT_9_CHAR     = 8'h39;

  
  reg key_char_is_letter; 
  reg key_char_is_digit;
  reg [6:0][6:0][7:0] nul_table = {49{NUL_CHAR}};
  
  reg err_repeated_char;
  reg err_invalid_key_char;

  integer word_counter = 0;
  integer digit_counter = 0;

  task expected_matrix (
     output [6:0][6:0][7:0] rot_table
  );
    
    //check presence of repeated or invalid characters in the key
    // (i*8)+7:i*8 = i*8 +: 8
    err_repeated_char = 0;
    err_invalid_key_char = 0;
    for(int i=0; i<12; i=i+1) begin
      key_char_is_letter = ((key_char[i*8 +: 8] >= UPPERCASE_A_CHAR) && (key_char[i*8 +: 8] <= UPPERCASE_Z_CHAR) ||  
                              (key_char[i*8 +: 8] >= LOWERCASE_A_CHAR) && (key_char[i*8 +: 8] <= LOWERCASE_Z_CHAR));
      key_char_is_digit = (key_char[i*8 +: 8] >= DIGIT_0_CHAR) && (key_char[i*8 +: 8] <= DIGIT_9_CHAR);
      err_invalid_key_char = err_invalid_key_char || !(key_char_is_letter || key_char_is_digit); 
      for(int j = 0; j< 12; j=j+1) begin
        if(i!=j) err_repeated_char = err_repeated_char || (key_char[i*8 +: 8] == key_char[j*8 +: 8]);
      end   
      if(err_repeated_char || err_invalid_key_char) break;
    end

    rot_table[0][0] = NUL_CHAR;
    if(!(err_repeated_char || err_invalid_key_char)) begin
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
  endtask
  
  initial begin
    @(reset_deassertion); // mi allineo a questo evento, ovvero lo aspetto
    
    @(posedge clk); // aspetto il fronte positivo
    
    fork

      begin: STIMULI_1R
        key_char = "abcdefghilmn";
        @(posedge clk);
        expected_matrix(EXPECTED_GEN);
	      for(int i = 0; i < 7; i++) begin
          for (int j = 0; j < 7; j++) begin
             $display("EG: (%d,%d) %c ",i,j, EXPECTED_GEN[i][j]);
          end
        end
        EXPECTED_QUEUE.push_back(EXPECTED_GEN);
      end: STIMULI_1R

      begin: CHECK_1R
        @(posedge clk);
        @(posedge clk);
        EXPECTED_CHECK = EXPECTED_QUEUE.pop_front();
        for(int i = 0; i < 7; i++) begin
          for (int j = 0; j < 7; j++) begin
            $display("%c %c %-5s", sub_char[i][j], EXPECTED_CHECK[i][j], EXPECTED_CHECK[i][j] === sub_char[i][j] ? "OK" : "ERROR");
          end
          //if(EXPECTED_CHECK != nul_table) $stop;
        end
      end: CHECK_1R
    join

    $stop;
    
  end

endmodule
// -----------------------------------------------------------------------------