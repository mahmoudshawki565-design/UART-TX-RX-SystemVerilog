module uart_controller (
    input  logic       CLK,RSTN,DATA_VALID,PAR_EN,data_done,
    output logic       load,shift,BUSY,
    output logic [1:0] mux_sel
);

    typedef enum logic [1:0] {START,  DATA,PARITY, STOP  
     } state_t;

    state_t cu_state, next_state;

    always_comb begin
        next_state = cu_state;

        case (cu_state)
            START: next_state = DATA;

            DATA: begin
                if (data_done)
                    next_state = PAR_EN ? PARITY : STOP;
            end

            PARITY: next_state = STOP;

            STOP: begin
                if (DATA_VALID)
                    next_state = START;
            end

            default: next_state = STOP;
        endcase
    end

    always_comb begin
        load    = 1'b0;
        shift   = 1'b0;
        mux_sel = 2'b01;
        BUSY    = 1'b1;

        case (cu_state)

            START: mux_sel = 2'b00;

            DATA: begin
                mux_sel = 2'b10;
                shift   = 1'b1;
            end

            PARITY: mux_sel = 2'b11;

            STOP: begin
                mux_sel = 2'b01;
                BUSY    = 1'b0;

                if (DATA_VALID)
                    load = 1'b1;
            end

        endcase
    end

    always_ff @(posedge CLK or negedge RSTN) begin
        if (!RSTN)
            cu_state <= STOP;
        else
            cu_state <= next_state;
    end

endmodule
