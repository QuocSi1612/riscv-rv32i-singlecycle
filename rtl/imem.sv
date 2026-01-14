module imem (
    input logic        i_clk,           // Clock input
    input logic [31:0] i_addr,          // 32-bit address input (from 0x0000 to 0x1FFF)
    output logic [31:0] o_instr         // 32-bit instruction output
  );

  // Memory array to hold instructions (1 KB = 256 words, each 32-bit wide)
  logic [31:0] memory [0:255];

  // Initial block to load memory contents (optional)
  initial
  begin
        $readmemh("/mnt/d/ComputerArchitecture/riscv_singlecycle/instruction.mem.txt", memory);

  end

  // Combinational read from memory
  always_comb
  begin
    if (i_addr >= 32'h0000 && i_addr <= 32'h03FF)
    begin
      o_instr = memory[i_addr[31:2]]; // Read instruction (using higher bits for indexing) , 2bit cuối luôn là 00 vì nó là bội của 4, nên không cần lấy
    end
    else
    begin
      o_instr = 32'h00000000;         // Default if address is out of range
    end
  end

endmodule
