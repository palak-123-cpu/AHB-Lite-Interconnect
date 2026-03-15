`timescale 1ns/1ps

// the boss of the bus — decides when and where to send/receive data
module ahb_master (
    input  wire        HRESETn, // reset everything when this goes low
    input  wire        HCLK,    // heartbeat of the whole system

    input  wire        HREADY,  // slave saying "i'm done, you can go"
    input  wire        HRESP,   // slave saying "ok" or "something went wrong"
    input  wire [31:0] HRDATA,  // data coming back from slave on a read

    output reg  [31:0] HADDR,    // address we want to read from or write to
    output reg         HWRITE,   // 1 = we're writing, 0 = we're reading
    output reg  [2:0]  HSIZE,    // how many bytes in this transfer
    output reg  [2:0]  HBURST,   // single transfer or a burst
    output reg  [3:0]  HPROT,    // access type info (privileged, data, etc.)
    output reg  [1:0]  HTRANS,   // tells slave if a real transfer is happening
    output reg         HMASTLOCK,// locks the bus so no one else can interrupt
    output reg  [31:0] HWDATA    // data we want to write to the slave
);

    localparam IDLE   = 2'b00; // bus doing nothing
    localparam NONSEQ = 2'b10; // starting a fresh transfer
    localparam SINGLE = 3'b000;// no burst, just one transfer

    localparam ST_IDLE      = 2'd0; // resting, getting ready
    localparam ST_ADDR      = 2'd1; // putting address on the bus
    localparam ST_DATA      = 2'd2; // sending or receiving actual data
    localparam ST_WAIT_RESP = 2'd3; // waiting for slave to confirm it's done

    reg [1:0] state, next_state;

    reg [31:0] addr_reg;  // holds the address we want to use
    reg        write_reg; // remembers if this is a write or read
    reg [31:0] wdata_reg; // holds the data we want to write
    reg [31:0] rdata_reg; // stores data we read back from slave

    // moves to the next state on every clock tick
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) state <= ST_IDLE;
        else          state <= next_state;
    end

    // works out what state comes next based on current state and HREADY
    always @(*) begin
        next_state = state;
        case (state)
            ST_IDLE:      next_state = ST_ADDR;
            ST_ADDR:      if (HREADY) next_state = ST_DATA;
            ST_DATA:      if (HREADY) next_state = ST_WAIT_RESP;
            ST_WAIT_RESP: if (HREADY) next_state = ST_IDLE;
            default:      next_state = ST_IDLE;
        endcase
    end

    // drives the actual bus signals depending on which state we're in
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HADDR     <= 32'h0;
            HWRITE    <= 1'b0;
            HSIZE     <= 3'b010;
            HBURST    <= SINGLE;
            HPROT     <= 4'b0011;
            HTRANS    <= IDLE;
            HMASTLOCK <= 1'b0;
            HWDATA    <= 32'h0;
            addr_reg  <= 32'h0;
            write_reg <= 1'b0;
            wdata_reg <= 32'h0;
            rdata_reg <= 32'h0;
        end else begin
            case (state)
                ST_IDLE: begin
                    HTRANS    <= IDLE;
                    addr_reg  <= 32'h1000_0000; // where we want to go
                    write_reg <= 1'b1;           // we're doing a write
                    wdata_reg <= 32'h0000_0000;  // data to write
                end

                ST_ADDR: begin
                    HADDR  <= addr_reg;  // put the address on the bus
                    HWRITE <= write_reg; // tell slave if it's a write or read
                    HSIZE  <= 3'b010;    // 32-bit word
                    HBURST <= SINGLE;    // just one transfer
                    HTRANS <= NONSEQ;    // signal that a real transfer is starting
                end

                ST_DATA: begin
                    HTRANS <= IDLE;          // no more transfers coming
                    if (write_reg)
                        HWDATA <= wdata_reg; // put our data on the bus
                end

                ST_WAIT_RESP: begin
                    if (!write_reg)
                        rdata_reg <= HRDATA; // save what the slave sent back
                end
            endcase
        end
    end

endmodule
