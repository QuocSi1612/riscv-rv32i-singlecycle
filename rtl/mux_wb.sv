module mux_wb (
    input logic [31:0] pc_four, o_alu_data, o_ld_data,  // Đầu vào 32-bit
    input logic [1:0] wb_sel,                          // Tín hiệu chọn 2-bit
    output logic [31:0] wb_data                        // Đầu ra 32-bit
);

always_comb begin
    unique case (wb_sel)
        2'b10: wb_data = pc_four;
        2'b01: wb_data = o_alu_data;
        2'b00: wb_data = o_ld_data;
        default: wb_data = 32'b0; // Đề phòng trường hợp wb_sel không hợp lệ
    endcase
end

endmodule
