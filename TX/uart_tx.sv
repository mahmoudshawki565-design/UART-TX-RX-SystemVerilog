module uart_tx #(parameter DATA_W = 8)
(
    input  logic i_clk,i_rst_n,i_par_en,i_par_odd,i_valid,
    input  logic [DATA_W-1:0] i_data,
    output logic o_tx,
    output logic o_busy
);

    logic load;
    logic shift;
    logic [1:0] mux_sel;
    logic serial_bit;
    logic parity_bit;
    logic data_done;

    uart_controller CONTROLLER (
        .CLK        (i_clk),
        .RSTN       (i_rst_n),
        .DATA_VALID (i_valid),
        .PAR_EN     (i_par_en),
        .data_done  (data_done),
        .load       (load),
        .shift      (shift),
        .mux_sel    (mux_sel),
        .BUSY       (o_busy)
    );


    serializer #(.n(DATA_W)) SERIALIZER (
        .CLK        (i_clk),
        .RSTN       (i_rst_n),
        .load       (load),
        .shift      (shift),
        .P_DATA     (i_data),
        .serial_bit (serial_bit),
        .data_done  (data_done)
    );


    parity_calculator #(.n(DATA_W)) PARITY_CALCULATOR (
        .CLK        (i_clk),
        .RSTN       (i_rst_n),
        .load       (load),
        .P_DATA     (i_data),
        .PAR_TYP    (i_par_odd),
        .parity_bit (parity_bit)
    );


    mux MUX (
        .sel        (mux_sel),
        .serial_bit (serial_bit),
        .parity_bit (parity_bit),
        .TX_OUT     (o_tx)
    );

endmodule