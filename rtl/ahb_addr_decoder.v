module ahb_addr_decoder (
    input  wire [31:0] HADDR,
    input  wire        valid,
    output reg  [3:0]  HSEL
);
    always @(*) begin
        HSEL = 4'b0000;
        if (valid) begin
            case (HADDR[13:12])
                2'b00: HSEL = 4'b0001; // Slave 0: 0x0000_0000 - 0x0000_0FFF
                2'b01: HSEL = 4'b0010; // Slave 1: 0x0000_1000 - 0x0000_1FFF
                2'b10: HSEL = 4'b0100; // Slave 2: 0x0000_2000 - 0x0000_2FFF
                2'b11: HSEL = 4'b1000; // Slave 3: 0x0000_3000 - 0x0000_3FFF
                default: HSEL = 4'b0000;
            endcase
        end
    end
endmodule
