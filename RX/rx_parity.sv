module rx_parity_checker #(parameter n = 8)
(
    input  logic CLK,logic RSTN, PAR_EN,PAR_TYP,parity_check,logic RX_IN,
    input  logic [n-1:0] P_DATA,
    output logic PARITY_ERROR
);

    logic parity_bit;

    always_ff @(posedge CLK or negedge RSTN) begin

        if (!RSTN) begin
            parity_bit   <= 1'b0;
            PARITY_ERROR <= 1'b0;
        end

        else begin

            if (!parity_check) begin
                PARITY_ERROR <= 1'b0;
            end

            else begin
                parity_bit <= RX_IN;

                if (PAR_EN) begin

                    if (PAR_TYP)
                        PARITY_ERROR <= (RX_IN != ~(^P_DATA));
                    else
                        PARITY_ERROR <= (RX_IN != ^P_DATA);

                end

                else begin
                    PARITY_ERROR <= 1'b0;
                end

            end
        end
    end

endmodule
