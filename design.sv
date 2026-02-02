module pipeline_reg #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   in_valid,
    output logic                   in_ready,
    input  logic [DATA_WIDTH-1:0]  in_data,

    output logic                   out_valid,
    input  logic                   out_ready,
    output logic [DATA_WIDTH-1:0]  out_data
);

    logic full;
    logic [DATA_WIDTH-1:0] data_q;

    assign out_valid = full;
    assign out_data  = data_q;

    assign in_ready = ~full || out_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full   <= 1'b0;
            data_q <= '0;
        end else begin
            case ({in_valid && in_ready, out_valid && out_ready})
                2'b10: begin
                    data_q <= in_data;
                    full   <= 1'b1;
                end
                2'b01: begin
                    full <= 1'b0;
                end
                2'b11: begin
                    data_q <= in_data;
                    full   <= 1'b1;
                end
                default: begin
                    full <= full;
                end
            endcase
        end
    end

endmodule
