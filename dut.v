module axi_handshake_reg (
    input  wire        clk,
    input  wire        rst_n,

    // Left Side: Connects to External Master (Module acts as Slave)
    input  wire [31:0] s_data,
    input  wire        s_valid,
    output wire        s_ready,

    // Right Side: Connects to External Slave (Module acts as Master)
    output wire [31:0] m_data,
    output wire        m_valid,
    input  wire        m_ready
);

    // Internal Registers
    reg [31:0] data_reg;
    reg        valid_reg;

    // Ready Signal Logic
    assign s_ready = m_ready | (~valid_reg);

    // Module Outputs
    assign m_data  = data_reg;
    assign m_valid = valid_reg;

    // Sequential Logic Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg <= 1'b0;
            data_reg  <= 32'h0;
        end else begin
            // Check if the module is ready to accept a new state
            if (s_ready) begin
                valid_reg <= s_valid;

                // Capture payload only when incoming data from Master is valid
                if (s_valid) begin
                    data_reg <= s_data;
                end
            end
        end
    end

endmodule
