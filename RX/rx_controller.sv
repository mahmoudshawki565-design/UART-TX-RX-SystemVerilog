module rx_controller (
    input  logic CLK, RSTN, RX_IN, PAR_EN, data_done,

    output logic load,
    output logic shift,
    output logic parity_en,
    output logic stop_check,
    output logic DATA_VALID,
    output logic BUSY
);

    typedef enum logic [1:0] {
        IDLE,
        DATA,
        PARITY,
        STOP
    } state_t;

    state_t CS, NS;


    // Next State
    always_comb begin

        NS = CS;

        case (CS)

            IDLE: begin
                if (RX_IN == 1'b0)
                    NS = DATA;
            end

            DATA: begin
                if (data_done) begin
                    if (PAR_EN)
                        NS = PARITY;
                    else
                        NS = STOP;
                end
            end

            PARITY: begin
                NS = STOP;
            end

            STOP: begin
                NS = IDLE;
            end

            default:
                NS = IDLE;

        endcase
    end


    // Current State
    always_ff @(posedge CLK or negedge RSTN) begin

        if (!RSTN)
            CS <= IDLE;

        else
            CS <= NS;

    end


    // Outputs
    always_comb begin

        load       = 1'b0;
        shift      = 1'b0;
        parity_en  = 1'b0;
        stop_check = 1'b0;
        DATA_VALID = 1'b0;
        BUSY       = 1'b0;

        case (CS)

            IDLE: begin
                load = 1'b1;
                BUSY = 1'b0;
            end

            DATA: begin
                shift = 1'b1;
                BUSY  = 1'b1;
            end

            PARITY: begin
                parity_en = 1'b1;
                BUSY      = 1'b1;
            end

            STOP: begin
                stop_check = 1'b1;
                DATA_VALID = 1'b1;
                BUSY       = 1'b0;
            end

        endcase
    end

endmodule