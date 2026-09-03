module parity_calculator #(parameter n = 8)
(
    input  logic CLK, RSTN, load, PAR_TYP,
    input  logic [n-1:0] P_DATA,
    output logic parity_bit
);

always_ff @(posedge CLK or negedge RSTN) begin
    if (!RSTN)
        parity_bit <= 1'b0;
    else if (load) begin
        if (PAR_TYP)
            parity_bit <= ~(^P_DATA);
        else
            parity_bit <= ^P_DATA;
    end
end

endmodule
