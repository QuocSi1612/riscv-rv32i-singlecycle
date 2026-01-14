module lsu (
    input  logic        i_clk,
    input  logic        i_rst,
    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_st_data,
    input  logic        i_lsu_wren,
    input  logic        i_lsu_rden,
    input  logic [2:0]  num_byte,
    output logic [31:0] o_ld_data,
    output logic [3:0]  i_BMASK,
    output logic        u
);

    logic [31:0] mem_data;
    logic [31:0] w_data_final;
    localparam DMEM_BASE = 32'h10000000;

    dmem_1KiB data_memory (
        .clk   (i_clk),
        .wr_en (i_lsu_wren && i_lsu_addr >= DMEM_BASE && i_lsu_addr < DMEM_BASE + 32'h400),
        .addr  ((i_lsu_addr - DMEM_BASE) >> 2),
        .w_data(w_data_final),
        .r_data(mem_data)
    );

    // --- Byte mask & unsigned flag ---
    always_comb begin
        i_BMASK = 4'b0000;
        u = 1'b0;
        case(num_byte)
            3'd0: i_BMASK = 4'b0001 << i_lsu_addr[1:0];
            3'd1: begin i_BMASK = 4'b0001 << i_lsu_addr[1:0]; u=1; end
            3'd2: i_BMASK = (i_lsu_addr[1]) ? 4'b1100 : 4'b0011;
            3'd3: begin i_BMASK = (i_lsu_addr[1]) ? 4'b1100 : 4'b0011; u=1; end
            3'd4: i_BMASK = 4'b1111;
            default: i_BMASK = 4'b0000;
        endcase
    end

    // --- Write data (masked) ---
    always_comb begin
        w_data_final = mem_data;
        if (i_lsu_wren && i_lsu_addr >= DMEM_BASE && i_lsu_addr < DMEM_BASE + 32'h400) begin
            case (num_byte)
                3'd0, 3'd1: begin
                    case (i_lsu_addr[1:0])
                        2'b00: w_data_final[7:0]   = i_st_data[7:0];
                        2'b01: w_data_final[15:8]  = i_st_data[7:0];
                        2'b10: w_data_final[23:16] = i_st_data[7:0];
                        2'b11: w_data_final[31:24] = i_st_data[7:0];
                    endcase
                end
                3'd2, 3'd3: begin
                    if (i_lsu_addr[1]==0) begin
                        w_data_final[15:0] = i_st_data[15:0];
                    end else begin
                        w_data_final[31:16] = i_st_data[15:0];
                    end
                end
                3'd4: w_data_final = i_st_data;
            endcase
        end
    end

    // --- Load data (combinational) ---
    always_comb begin
        if (i_lsu_rden) begin
            case (i_BMASK)
                4'b0001: o_ld_data = u ? {24'b0, mem_data[7:0]}   : {{24{mem_data[7]}}, mem_data[7:0]};
                4'b0010: o_ld_data = u ? {24'b0, mem_data[15:8]}  : {{24{mem_data[15]}}, mem_data[15:8]};
                4'b0100: o_ld_data = u ? {24'b0, mem_data[23:16]} : {{24{mem_data[23]}}, mem_data[23:16]};
                4'b1000: o_ld_data = u ? {24'b0, mem_data[31:24]} : {{24{mem_data[31]}}, mem_data[31:24]};
                4'b0011: o_ld_data = u ? {16'b0, mem_data[15:0]}  : {{16{mem_data[15]}}, mem_data[15:0]};
                4'b1100: o_ld_data = u ? {16'b0, mem_data[31:16]} : {{16{mem_data[31]}}, mem_data[31:16]};
                4'b1111: o_ld_data = mem_data;
                default: o_ld_data = 32'b0;
            endcase
        end else
            o_ld_data = 32'b0;
    end

endmodule
