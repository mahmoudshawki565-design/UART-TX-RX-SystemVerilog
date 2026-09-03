module rx_serializer #(parameter n = 8)
(
    input  logic CLK, RSTN, shift, RX_IN,
    output logic [n-1:0] P_DATA,
    output logic data_done
);

    logic [n-1:0] shift_reg;
    logic [$clog2(n)-1:0] cnt;

    assign data_done = shift && (cnt == n-1);   // Instant with no cycle delay
    always_ff @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            shift_reg <= 0;
            cnt       <= 0;
            P_DATA    <= 0;
        end
        else if (shift) begin
            shift_reg[cnt] <= RX_IN;
            if (cnt == n-1) begin
                P_DATA <= {RX_IN, shift_reg[n-2:0]};
                cnt    <= 0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
endmodule