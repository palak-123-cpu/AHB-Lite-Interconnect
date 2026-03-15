`timescale 1ns/1ps

// stores and gives back data — like a small memory chip on the bus
module ahb_slave (
    input  wire        HRESETn,  // wipe everything clean when low
    input  wire        HCLK,     // clock

    input  wire        HSELX,    // decoder saying "hey, this one's for you"
    input  wire [31:0] HADDR,    // where to read from or write to
    input  wire        HWRITE,   // 1 = write coming, 0 = read coming
    input  wire [1:0]  HTRANS,   // is this a real transfer or just idle?
    input  wire [2:0]  HSIZE,    // how many bytes
    input  wire [2:0]  HBURST,   // burst info
    input  wire [3:0]  HPROT,    // access type
    input  wire        HMASTLOCK,// locked transfer flag
    input  wire        HREADY,   // bus saying it's safe to latch new address
    input  wire [31:0] HWDATA,   // data the master wants to write

    output wire [31:0] HRDATA,   // data we send back on a read
    output wire        HREADYOUT,// we're always ready — no wait states
    output wire        HRESP     // always OKAY — no errors
);

    localparam NONSEQ = 2'b10; // real new transfer
    localparam SEQ    = 2'b11; // continuing a burst

    assign HRESP     = 1'b0; // always tell master everything is fine
    assign HREADYOUT = 1'b1; // always ready instantly

    reg [31:0] mem [0:63]; // 64 words of storage (256 bytes total)
    integer    idx;

    reg [31:0] addr_lat;  // saved address from last cycle
    reg        write_lat; // saved direction from last cycle
    reg        valid_lat; // was the last cycle actually meant for us?

    // on every clock, save the address info for use next cycle
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_lat  <= 32'h0;
            write_lat <= 1'b0;
            valid_lat <= 1'b0;
        end else if (HREADY) begin
            addr_lat  <= HADDR;  // save address before it changes next cycle
            write_lat <= HWRITE;
            valid_lat <= HSELX && (HTRANS == NONSEQ || HTRANS == SEQ); // only count real transfers
        end
    end

    // if it was a valid write last cycle, store the data now
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            for (idx = 0; idx < 64; idx = idx + 1)
                mem[idx] <= 32'h0; // clear all memory on reset
        end else begin
            if (valid_lat && write_lat)
                mem[addr_lat[7:2]] <= HWDATA; // addr[7:2] gives the word index
        end
    end

    // send back read data immediately — no clock delay
    assign HRDATA = (valid_lat && !write_lat) ? mem[addr_lat[7:2]] : 32'h0;

endmodule
