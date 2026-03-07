module ahb_lite_slave (
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire [31:0] HADDR,
    input  wire [1:0]  HTRANS,
    input  wire        HWRITE,
    input  wire [2:0]  HSIZE,
    input  wire [31:0] HWDATA,
    input  wire        HSEL,

    output reg  [31:0] HRDATA,
    output reg         HREADYOUT,
    output reg         HRESP
);

    reg [31:0] mem [0:1023]; // 1024 words = 4KB
    integer i;

    wire valid = HSEL && (HTRANS == 2'b10);
    wire [9:0] word_addr = HADDR[11:2];

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HREADYOUT <= 1;
            HRESP <= 0;
            HRDATA <= 0;
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 0;
        end else begin
            HREADYOUT <= 1;
            HRESP <= 0;

            if (valid) begin
                if (HWRITE) begin
                    case (HSIZE)
                        3'b000: mem[word_addr][8*HADDR[1:0] +: 8] <= HWDATA[7:0];   // byte
                        3'b001: mem[word_addr][16*HADDR[1] +: 16]     <= HWDATA[15:0]; // halfword
                        3'b010: mem[word_addr]                         <= HWDATA;        // word
                        default: ;
                    endcase
                end else begin
                    case (HSIZE)
                        3'b000: HRDATA <= {24'b0, mem[word_addr][8*HADDR[1:0] +: 8]};   // byte read
                        3'b001: HRDATA <= {16'b0, mem[word_addr][16*HADDR[1] +: 16]};   // halfword read
                        3'b010: HRDATA <= mem[word_addr];                               // word read
                        default: HRDATA <= 32'b0;
                    endcase
                end
            end
        end
    end
endmodule

