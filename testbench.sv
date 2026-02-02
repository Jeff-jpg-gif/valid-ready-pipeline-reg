module tb_pipeline_reg;

    localparam int DATA_WIDTH = 8;

    logic clk;
    logic rst_n;

    logic in_valid;
    logic in_ready;
    logic [DATA_WIDTH-1:0] in_data;

    logic out_valid;
    logic out_ready;
    logic [DATA_WIDTH-1:0] out_data;

    logic [DATA_WIDTH-1:0] stalled_data;
    logic was_stalled;

    pipeline_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid (out_valid),
        .out_ready (out_ready),
        .out_data  (out_data)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset
    initial begin
        rst_n      = 0;
        in_valid  = 0;
        in_data   = '0;
        out_ready = 0;
        was_stalled = 0;
        stalled_data = '0;

        #20 rst_n = 1;
    end

    // Waveforms
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_pipeline_reg);
    end

    task send(input logic [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            in_valid <= 1'b1;
            in_data  <= data;
            while (!in_ready)
                @(posedge clk);
            @(posedge clk);
            in_valid <= 1'b0;
        end
    endtask

      task consume;
          begin
              // Assert ready
              out_ready <= 1'b1;

              // Wait for handshake, not just valid
              @(posedge clk);
              while (!(out_valid && out_ready))
                  @(posedge clk);

              $display("Time %0t: Consumed data = %0d",
                       $time, out_data);

              // Deassert ready after successful transfer
              @(posedge clk);
              out_ready <= 1'b0;
          end
      endtask

    // Tests
    initial begin
        @(posedge rst_n);
        @(posedge clk);

        $display("=== Test 1: Simple transfer ===");
        send(8'd10);
        consume();

        $display("=== Test 2: Backpressure ===");
        out_ready = 0;
        send(8'd20);
        #30;
        consume();

        $display("=== Test 3: Flow-through ===");
        out_ready = 1;
        fork
            send(8'd30);
            consume();
        join

        $display("=== Test 4: Stall then release ===");
        send(8'd40);
        #40;
        consume();

        $display("All tests completed.");
        #20;
        $finish;
    end

    // ✅ Correct stall checker
    always @(posedge clk) begin
        if (out_valid && !out_ready) begin
            if (was_stalled && out_data !== stalled_data) begin
                $error("ERROR: out_data changed during stall!");
            end
            stalled_data <= out_data;
            was_stalled  <= 1'b1;
        end else begin
            was_stalled <= 1'b0;
        end
    end

endmodule
