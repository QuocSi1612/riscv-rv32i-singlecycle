module singlecycle (

    input logic i_clk,
    input logic i_rst_n
);

  logic [31:0] alu_data, pc_next , pc, pc_four , instr , wb_data , rs1_data , rs2_data , imm_gen , operand_a, operand_b , ld_data;

  logic [3-1:0] imm_sel;

  logic pc_sel , rd_wren , br_un , br_less , br_equal , opa_sel , opb_sel, mem_wren , mem_read;

  logic [4-1:0]  alu_op;

  logic [2-1:0] wb_sel;

  logic [2:0] num_byte_temp;

  // -----------------------------
  mux_before_PC pc3(
    .PC_plus_four_i(pc_four),
    .alu_i(alu_data),
    .sel(pc_sel),
    .mux_before_PC_o(pc_next)
  );

  pc pc2(
    .i_clk(i_clk),
    .i_rst(i_rst_n),
    .i_mux_before_pc(pc_next),
    .en_pc(1'b1),
    .o_pc(pc)
  );

  pc_plus_four pc1(
    .i_pc(pc),
    .o_pc_plus_four(pc_four)
  );

  imem imem0(
    .i_clk(i_clk),
    .i_addr(pc),
    .o_instr(instr)
  );

  regfile regfile0(
    .i_clk(i_clk),
    .i_rst(i_rst_n),
    .i_rd_wren(rd_wren),
    .i_rd_addr(instr[11:7]),
    .i_rs1_addr(instr[19:15]),
    .i_rs2_addr(instr[24:20]),
    .i_rd_data(wb_data),
    .o_rs1_data(rs1_data),
    .o_rs2_data(rs2_data)
  );

  imm_gen imm0(
    .i_inst(instr),
    .imm_sel(imm_sel),
    .o_imm(imm_gen)
  );

  brc brc0(
    .i_rs1_data(rs1_data),
    .i_rs2_data(rs2_data),
    .i_br_un(br_un),
    .o_br_less(br_less),
    .o_br_equal(br_equal)
  );

  mux_op_a opa(
    .pc(pc),
    .o_rs1_data(rs1_data),
    .opa_sel(opa_sel),
    .op_a(operand_a)
  );

  mux_op_b opb(
    .imm(imm_gen),
    .o_rs2_data(rs2_data),
    .opb_sel(opb_sel),
    .op_b(operand_b)
  );

  alu alu0(
    .i_alu_op(alu_op),
    .i_operand_a(operand_a),
    .i_operand_b(operand_b),
    .o_alu_data(alu_data)
  );

  // ---- LSU (đơn giản, chỉ có dmem) ----
  lsu lsu0(
    .i_clk(i_clk),
    .i_rst(i_rst_n),
    .i_lsu_addr(alu_data),
    .i_st_data(rs2_data),
    .i_lsu_wren(mem_wren),
    .i_lsu_rden(mem_read),
    .num_byte(num_byte_temp),
    .o_ld_data(ld_data)
    //.i_BMASK('0),  // Thêm port này
    //.u('0)         // Thêm port này
  );

  mux_wb mux0(
    .pc_four(pc_four),
    .o_alu_data(alu_data),
    .o_ld_data(ld_data),
    .wb_sel(wb_sel),
    .wb_data(wb_data)
  );

  control_unit ctrl(
    .inst(instr),
    .br_less(br_less),
    .br_eqal(br_equal),
    .pc_sel(pc_sel),
    .rd_wren(rd_wren),
    .br_un(br_un),
    .opa_sel(opa_sel),
    .opb_sel(opb_sel),
    .mem_wren(mem_wren),
    .mem_read(mem_read),
    .alu_op(alu_op),
    .wb_sel(wb_sel),
    .imm_sel(imm_sel),
    .num_byte(num_byte_temp)
  );

endmodule
