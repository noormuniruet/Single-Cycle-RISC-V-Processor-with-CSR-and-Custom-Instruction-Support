module tb_processor();
    logic clk;
    logic rst;

    processor dut
    (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generator
    initial
    begin
        clk = 0;
        forever
        begin
            #5 clk = ~clk;
        end
    end

    // Reset Generator
    initial
    begin
        rst = 1;
        #10;
        rst = 0;
        #5000; // Increased time for instruction execution
        $finish;
    end

    // Initializing CSR file
    initial
    begin
        #10 rst = 0; // Deassert reset
        #5 $readmemb("csr_register_file", dut.csr_inst.csr_mem); // Initialize after reset
    end

    // Initializing memory
    initial
    begin
        $readmemb("instruction_memory", dut.imem.mem);         // Instruction Memory
        $readmemb("register_file", dut.reg_file_inst.reg_mem); // Register File
        $readmemb("data_memory", dut.data_mem_inst.data_memory); // Data Memory
    end

    // Testing lwpostinc Instruction
    initial
    begin
        // Initialize specific test for lwpostinc
        #15;
        // Add initialization of rs1, immediate values, or other required inputs in `register_file` or `data_memory`.
        // Example: Write specific test cases in "register_file" and "data_memory" files to verify lwpostinc.
        $display("Executing lwpostinc Test...");
        #100; // Allow time for execution and observe results
        $finish;
    end

    // Dumping output
    initial
    begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb_processor);
        $dumpvars(1, dut.reg_file_inst.reg_mem); // Dump register file values
        $dumpvars(2, dut.csr_inst.csr_mem);
        $dumpvars(3, dut.data_mem_inst.data_memory); // Dump data memory values
    end

endmodule
