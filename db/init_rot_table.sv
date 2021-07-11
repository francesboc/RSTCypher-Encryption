/*
Notes:
 1) How to detect repeated char?
    -   first idea: feedback wire from output reg 'sub_char' to the input 'previous_char' and compare with key_char
        that is initialized with NULL char (8'h00) (maybe previous_char not needed)
*/

module initTable (
  input            clk,
  input            rst_n,
  input      [7:0] previous_char, // contains the previous computed character
  input      [7:0] key_char,
  output reg [7:0] sub_char,
  output           err_repeated_char, // flag to detect repeated characters
  output           err_invalid_key_char // flag to detect invalid characters   
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

  wire key_char_is_letter;
  wire key_char_is_digit;

  // ---------------------------------------------------------------------------
  // Logic Design
  // ---------------------------------------------------------------------------

  assign key_char_is_letter = ((key_char >= UPPERCASE_A_CHAR) && (key_char <= UPPERCASE_Z_CHAR) || 
                               (key_char >= LOWERCASE_A_CHAR) && (key_char <= LOWERCASE_Z_CHAR));
  
  assign key_char_is_digit = (key_char >= DIGIT_0_CHAR) && (key_char <= DIGIT_9_CHAR);

  assign err_invalid_key_char = !(key_char_is_letter || key_char_is_digit);

  assign err_repeated_char = 0; // TODO: implement this logic

  // Table initialization
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      previous_char <= NUL_CHAR;
    else if(sub_char === key_char)
      err_repeated_char = 1'b1;
    else if(err_invalid_key_char || err_repeated_char)
      sub_char <= NUL_CHAR;
    else
      sub_char <= key_char;
  end

endmodule