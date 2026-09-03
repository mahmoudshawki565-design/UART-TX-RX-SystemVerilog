module uart_rx #(parameter DATA_W = 8)
(
    input  logic i_clk,i_rst_n,i_rx,i_par_en,i_par_odd,
    output logic  o_valid,
    output logic o_busy,
    output logic o_parity_err,o_frame_err,
    output logic [DATA_W-1:0] o_data
);

    logic load, shift, parity_en, stop_check, data_done;
    logic [DATA_W-1:0] rx_data;
    logic valid_raw, parity_err_raw, frame_err_raw;

    rx_controller CONTROLLER (
        .CLK(i_clk), .RSTN(i_rst_n), .RX_IN(i_rx), .PAR_EN(i_par_en),
        .data_done(data_done),
        .load(load), .shift(shift), .parity_en(parity_en),
        .stop_check(stop_check), .DATA_VALID(valid_raw), .BUSY(o_busy)
    );

    rx_serializer #(.n(DATA_W)) SERIALIZER (
        .CLK(i_clk), .RSTN(i_rst_n), .shift(shift), .RX_IN(i_rx),
        .P_DATA(rx_data), .data_done(data_done)
    );

    rx_parity_checker #(.n(DATA_W)) PARITY_CHECKER (
        .CLK(i_clk), .RSTN(i_rst_n), .PAR_EN(i_par_en), .PAR_TYP(i_par_odd),
        .parity_check(parity_en), .RX_IN(i_rx), .P_DATA(rx_data),
        .PARITY_ERROR(parity_err_raw)
    );

    assign frame_err_raw = stop_check && (i_rx != 1'b1);

    always_ff @(posedge i_clk or negedge i_rst_n) begin  //check error
        if (!i_rst_n) begin
            o_valid      <= 1'b0;
            o_data       <= '0;
            o_parity_err <= 1'b0;
            o_frame_err  <= 1'b0;
        end else begin
            o_valid <= valid_raw;
            if (valid_raw) begin
                o_data       <= rx_data;
                o_parity_err <= parity_err_raw;
                o_frame_err  <= frame_err_raw;
            end
        end
    end

endmodule