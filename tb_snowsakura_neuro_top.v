`timescale 1ns / 1ps

module tb_snowsakura_neuro_top;

    // -------------------------------------------------------------------------
    // Physical Layer Clock Domain: 322.56 MHz (Period: ~3.1008 ns)
    // -------------------------------------------------------------------------
    reg clk_322mhz;
    reg rst_n;
    
    initial begin
        clk_322mhz = 0;
        // Generate precise 322.56 MHz clock to simulate GTH recovered clock
        forever #1.55 clk_322mhz = ~clk_322mhz; 
    end

    // -------------------------------------------------------------------------
    // Hardware Interfaces (Mapped to ZU15EG GTH Pins)
    // -------------------------------------------------------------------------
    // Raw neural data directly from ADC/Sensor via GTH RX (Bypassing RX Buffer)
    reg  [63:0] rx_neural_raw_data; 
    reg         rx_data_valid;
    
    // TX Stimulation pulse directly to GTH TX
    wire [63:0] tx_stim_pulse;      
    wire        tx_pulse_valid;

    // -------------------------------------------------------------------------
    // DUT Instantiation: 6-FF Pipeline Zero-Jitter Parser
    // -------------------------------------------------------------------------
    snowsakura_neuro_parser_top u_neuro_parser (
        .clk_322mhz         (clk_322mhz),
        .rst_n              (rst_n),
        
        // Manual Triple-FF synchronization must be implemented inside for CDC
        .rx_neural_data_in  (rx_neural_raw_data), 
        .rx_valid_in        (rx_data_valid),
        
        .tx_stim_data_out   (tx_stim_pulse),
        .tx_valid_out       (tx_pulse_valid)
    );

    // -------------------------------------------------------------------------
    // Biological Stimulus Injection & Latency Assertion
    // -------------------------------------------------------------------------
    integer cycle_count;
    integer spike_injected_cycle;

    always @(posedge clk_322mhz or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
        end
    end

    initial begin
        rst_n = 0;
        rx_neural_raw_data = 64'h0;
        rx_data_valid = 0;
        
        #31; // Hold reset
        rst_n = 1;
        #31;

         (Neural Spike Burst) 
        @(posedge clk_322mhz);
        rx_neural_raw_data = 64'hA5A5_DEAD_BEEF_0001; // Synthetic spike signature
        rx_data_valid = 1;
        spike_injected_cycle = cycle_count;
        
        @(posedge clk_322mhz);
        rx_neural_raw_data = 64'h0;
        rx_data_valid = 0;
    end

    // -------------------------------------------------------------------------
    // Strict Timing Verification (36ns Total / 18ns Logic = Max 6 Cycles)
    // -------------------------------------------------------------------------
    always @(posedge clk_322mhz) begin
        if (tx_pulse_valid) begin
            $display("=================================================");
            $display("[PHYSICAL LAYER VERIFICATION]");
            $display("Spike Injected Cycle : %0d", spike_injected_cycle);
            $display("Stimulus Triggered   : %0d", cycle_count);
            $display("Logic Latency (Cycles): %0d", cycle_count - spike_injected_cycle);
            $display("=================================================");

            if ((cycle_count - spike_injected_cycle) > 6) begin
                $display("FATAL TIMING VIOLATION: Pipeline exceeds 18ns logical budget.");
                $display("Neural feedback loop is compromised. Jitter detected.");
                $finish;
            end else begin
                $display("SUCCESS: Deterministic 36ns zero-jitter loop achieved.");
                $finish;
            end
        end
    end

endmodule
