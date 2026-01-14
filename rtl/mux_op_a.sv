module mux_op_a (
input logic [31:0] pc, o_rs1_data,
input logic opa_sel,
output logic [31:0] op_a
);
assign op_a = opa_sel ? pc: o_rs1_data;
endmodule 