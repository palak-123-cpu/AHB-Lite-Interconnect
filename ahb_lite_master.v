module ahb_lite_master (
    input  wire        HCLK,
    input  wire        HRESETn,
    input  wire        start_trans,
    input  wire [31:0] addr_in,
    input  wire        write_en,
    input  wire [31:0] wdata_in,
    input  wire [2:0]  size_type,
    input  wire [31:0] HRDATA,
    input  wire        HREADY,

    output reg  [31:0] HADDR,
    output reg  [1:0]  HTRANS,
    output reg         HWRITE,
    output reg  [2:0]  HSIZE,
    output reg  [31:0] HWDATA,
    output reg  [31:0] rdata_out,
    output reg         trans_done
);

    localparam IDLE   = 2'b00;
    localparam NONSEQ = 2'b10;

    reg busy;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR <= 0;
            HTRANS <= IDLE;
            HWRITE <= 0;
            HSIZE <= 3'b010; // word
            HWDATA <= 0;
            rdata_out <= 0;
            trans_done <= 0;
            busy <= 0;
        end else begin
            trans_done <= 0;

            if (start_trans && !busy) begin
                HADDR  <= addr_in;
                HWRITE <= write_en;
                HSIZE  <= size_type;
                HWDATA <= wdata_in;
                HTRANS <= NONSEQ;
                busy   <= 1;
            end
            else if (busy && HREADY) begin
                if (!HWRITE)
                    rdata_out <= HRDATA;

                HTRANS <= IDLE;
                trans_done <= 1;
                busy <= 0;
            end
        end
    end
endmodule
