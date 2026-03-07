module ahb_resp_mux (
    input  wire [3:0]  HSEL,

    input  wire [31:0] HRDATA0, HRDATA1, HRDATA2, HRDATA3,
    input  wire        HREADY0, HREADY1, HREADY2, HREADY3,
    input  wire        HRESP0,  HRESP1,  HRESP2,  HRESP3,

    output reg  [31:0] HRDATA,
    output reg         HREADY,
    output reg         HRESP
);
    always @(*) begin
        // default safe values
        HRDATA = 32'b0;
        HREADY = 1'b1;
        HRESP  = 1'b0;

        case (HSEL)
            4'b0001: begin HRDATA = HRDATA0; HREADY = HREADY0; HRESP = HRESP0; end
            4'b0010: begin HRDATA = HRDATA1; HREADY = HREADY1; HRESP = HRESP1; end
            4'b0100: begin HRDATA = HRDATA2; HREADY = HREADY2; HRESP = HRESP2; end
            4'b1000: begin HRDATA = HRDATA3; HREADY = HREADY3; HRESP = HRESP3; end
            default: begin /* no slave selected: keep defaults */ end
        endcase
    end
endmodule
