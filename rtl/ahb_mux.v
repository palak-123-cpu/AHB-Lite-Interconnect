`timescale 1ns/1ps

// picks which slave's data to send back to the master
module ahb_mux (
    input  wire        HCLK,      // clock
    input  wire        HRESETn,   // reset
    input  wire        HREADY_IN, // tells us when it's safe to update our selection

    input  wire        HSEL_1, // slave 1 was selected this cycle
    input  wire        HSEL_2, // slave 2 was selected this cycle
    input  wire        HSEL_3, // slave 3 was selected this cycle

    input  wire [31:0] HRDATA_1, // read data from slave 1
    input  wire [31:0] HRDATA_2, // read data from slave 2
    input  wire [31:0] HRDATA_3, // read data from slave 3

    input  wire        HREADYOUT_1, // slave 1 ready signal
    input  wire        HREADYOUT_2, // slave 2 ready signal
    input  wire        HREADYOUT_3, // slave 3 ready signal

    input  wire        HRESP_1, // slave 1 response
    input  wire        HRESP_2, // slave 2 response
    input  wire        HRESP_3, // slave 3 response

    output reg  [31:0] HRDATA, // data going back to master
    output reg         HREADY, // ready signal going back to master
    output reg         HRESP   // response going back to master
);

    reg [2:0] sel_lat; // remembers which slave was picked one cycle ago

    // save the current selection — we need it one cycle later for the data phase
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            sel_lat <= 3'b000;
        else if (HREADY_IN)
            sel_lat <= {HSEL_3, HSEL_2, HSEL_1};
    end

    // forward the right slave's data to the master
    always @(*) begin
        case (sel_lat)
            3'b001: begin // slave 1 was chosen
                HRDATA = HRDATA_1;
                HREADY = HREADYOUT_1;
                HRESP  = HRESP_1;
            end
            3'b010: begin // slave 2 was chosen
                HRDATA = HRDATA_2;
                HREADY = HREADYOUT_2;
                HRESP  = HRESP_2;
            end
            3'b100: begin // slave 3 was chosen
                HRDATA = HRDATA_3;
                HREADY = HREADYOUT_3;
                HRESP  = HRESP_3;
            end
            default: begin // nobody selected — bus is idle
                HRDATA = 32'h0;
                HREADY = 1'b1; // bus stays ready when idle
                HRESP  = 1'b0; // OKAY
            end
        endcase
    end

endmodule
