module dmem_1KiB (
    input  logic        clk,
    input  logic        wr_en,   // mem_wren
    input  logic        rd_en,   // mem_read
    input  logic [7:0]  addr,    // 256 word
    input  logic [31:0] w_data,
    output logic [31:0] r_data
);

    logic [31:0] ram [0:255];

    // --- synchronous write ---
    always_ff @(posedge clk) begin
        if(wr_en)
            ram[addr] <= w_data;
    end

    // --- combinational read ---
    //assign r_data = rd_en ? ram[addr] : 32'b0;
    assign r_data = ram[addr];
endmodule
