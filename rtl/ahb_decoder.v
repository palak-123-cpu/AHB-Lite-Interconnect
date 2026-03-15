`timescale 1ns/1ps

// looks at the address and picks which slave should respond
module ahb_decoder (
    input  wire [31:0] HADDR,  // address from the master
    output reg         HSEL_1, // selects slave 1
    output reg         HSEL_2, // selects slave 2
    output reg         HSEL_3  // selects slave 3
);

    // no clock needed — fires instantly whenever HADDR changes
    always @(*) begin
        HSEL_1 = 1'b0; // nobody selected by default
        HSEL_2 = 1'b0;
        HSEL_3 = 1'b0;

        case (HADDR[31:28]) // top 4 bits tell us which region we're in
            4'h1 : HSEL_1 = 1'b1; // 0x1000_0000 range → pick slave 1
            4'h2 : HSEL_2 = 1'b1; // 0x2000_0000 range → pick slave 2
            4'h3 : HSEL_3 = 1'b1; // 0x3000_0000 range → pick slave 3
            default: ;             // address is out of range — no one answers
        endcase
    end

endmodule
