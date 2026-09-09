`timescale 1ns / 1ps

module tb_axi_handshake_reg;

    // Clock and Reset
    reg        clk;
    reg        rst_n;

    // Interface with External Master (Slave Port on DUT)
    reg  [31:0] s_data;
    reg         s_valid;
    wire        s_ready;

    // Interface with External Slave (Master Port on DUT)
    wire [31:0] m_data;
    wire        m_valid;
    reg         m_ready;

    // Instantiate the Design Under Test (DUT)
    axi_handshake_reg dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .s_data  (s_data),
        .s_valid (s_valid),
        .s_ready (s_ready),
        .m_data  (m_data),
        .m_valid (m_valid),
        .m_ready (m_ready)
    );

    // 100MHz Clock Generation (10ns period)
    always begin
        #5 clk = ~clk;
    end

    // Main Test Stimulus Sequence
    initial begin
        // Initialize Signals
        clk     = 1'b0;
        rst_n   = 1'b0;
        s_data  = 32'h0000_0000;
        s_valid = 1'b0;
        m_ready = 1'b0;

        // Apply Reset
        #20;
        rst_n = 1'b1;
        #10;

        $display("=== STARTING SIMULATION ===");

        // -------------------------------------------------------------
        // TEST 1: Single Data Beat Transfer (Back-to-Back Ready)
        // -------------------------------------------------------------
        $display("[TEST 1] Single Data Transfer");
        @(posedge clk);
        s_data  <= 32'hAAAA_BBBB;
        s_valid <= 1'b1;
        m_ready <= 1'b1;

        @(posedge clk);
        s_valid <= 1'b0; // Master stops sending data

        @(posedge clk);
        if (m_data == 32'hAAAA_BBBB && m_valid == 1'b0) begin
            $display("-> TEST 1 PASSED: Data passed through and register cleared correctly.");
        end else begin
            $display("-> TEST 1 FAILED: m_data = %h, m_valid = %b", m_data, m_valid);
        end

        #20;

        // -------------------------------------------------------------
        // TEST 2: Backpressure Handling (Slave Not Ready)
        // -------------------------------------------------------------
        $display("[TEST 2] Backpressure Stall Test");
        @(posedge clk);
        s_data  <= 32'h1234_5678;
        s_valid <= 1'b1;
        m_ready <= 1'b0; // External Slave is NOT ready

        @(posedge clk);
        // Master drops valid, but data should remain trapped in DUT
        s_valid <= 1'b0;
        
        // Verify register holds data and s_ready goes LOW (Full)
        if (m_valid == 1'b1 && s_ready == 1'b0) begin
            $display("-> Register is FULL and correctly applying backpressure (s_ready = 0)");
        end

        #20;

        // Slave becomes ready to accept the trapped data
        @(posedge clk);
        m_ready <= 1'b1;

        @(posedge clk);
        m_ready <= 1'b0;

        if (m_valid == 1'b0 && s_ready == 1'b1) begin
            $display("-> TEST 2 PASSED: Data drained and s_ready restored to 1.");
        end else begin
            $display("-> TEST 2 FAILED.");
        end

        #20;

        // -------------------------------------------------------------
        // TEST 3: Clearing Test (Master Drives s_valid = 0 when s_ready = 1)
        // -------------------------------------------------------------
        $display("[TEST 3] Empty Cycle Verification");
        @(posedge clk);
        s_valid <= 1'b0;
        m_ready <= 1'b1;

        @(posedge clk);
        if (valid_reg_check(m_valid) == 0) begin
            $display("-> TEST 3 PASSED: valid_reg correctly loaded s_valid = 0.");
        end

        #20;
        $display("=== SIMULATION COMPLETED SUCCESSFULLY ===");
        $finish;
    end

    // Helper Function for Verification
    function valid_reg_check;
        input val;
        begin
            valid_reg_check = val;
        end
    endfunction

endmodule
