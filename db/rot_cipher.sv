module moduleName (
    input            clk,
    input            rst_n,
    input      [7:0] ptxt_char,
    output reg [7:0] ctxt_char,
    output           err_invalid_ptxt_char
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

// ---------------------------------------------------------------------------
// Logic Design
// ---------------------------------------------------------------------------

endmodule