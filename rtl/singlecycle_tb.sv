`timescale 1ns/1ps
module tb;

  logic clk;
  logic rst_n;

  // --- Instantiate DUT ---
  singlecycle dut (
    .i_clk(clk),
    .i_rst_n(rst_n)
  );

  // --- Clock generation ---
  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 50 MHz
  end

  // --- Reset ---
  initial begin
    rst_n = 0;
    #25;
    rst_n = 1;
  end

  // --- Log registers and memory when PC changes ---
  logic [31:0] prev_pc;
  initial prev_pc = 32'hFFFFFFFF;

  always @(posedge clk) begin
    if (rst_n && (dut.pc != prev_pc)) begin
        $display("# Time=%0t | PC=%08h | Instr=%08h | ALU=%08h | LD_DATA=%08h",
                 $time, dut.pc, dut.instr, dut.alu_data, dut.ld_data);

        // --- Registers ---
        for (int i = 0; i < 32; i=i+1)
            $display("# x%0d = %08h", i, dut.regfile0.regfile[i]);

        // --- DMEM (1KiB = 256 words) ---
        $display("# ---- DMEM ----");
        for (int i = 0; i < 256; i=i+1)
            $display("# mem[%0d] = %08h", i, dut.lsu0.data_memory.ram[i]);

        $display("# ---------------------------------------------");
        prev_pc = dut.pc;
    end
  end

  // --- Simulation stop ---
  initial begin
    #500; // simulation time limit
    $finish;
  end

endmodule  