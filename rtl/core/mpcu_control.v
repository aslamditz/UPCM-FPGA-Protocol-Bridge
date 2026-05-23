module mpcu_controller (

    input  wire       clk,
    input  wire       rst,

    input  wire [1:0] cose,
    input  wire       bridge_valid,

    input  wire       uart_done,
    input  wire       spi_done,
    input  wire       i2c_done,

    output reg        uart_start,
    output reg        spi_start,
    output reg        i2c_start,

    output reg        busy
);

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam WAIT  = 3'd2;

    reg [2:0] state;
    reg [1:0] active_protocol;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            uart_start <= 0;
            spi_start  <= 0;
            i2c_start  <= 0;
            busy <= 0;
            active_protocol <= 2'b00;
        end 
        else begin

            // default pulses
            uart_start <= 0;
            spi_start  <= 0;
            i2c_start  <= 0;

            case (state)

                // ========================
                IDLE: begin
                    busy <= 0;

                    if (bridge_valid && cose != 2'b00) begin
                        active_protocol <= cose;
                        busy  <= 1;
                        state <= START;
                    end
                end

                // ========================
                START: begin
                    case (active_protocol)
                        2'b01: uart_start <= 1;
                        2'b10: spi_start  <= 1;
                        2'b11: i2c_start  <= 1;
                    endcase
                    state <= WAIT;
                end

                // ========================
                WAIT: begin
                    case (active_protocol)
                        2'b01: if (uart_done) state <= IDLE;
                        2'b10: if (spi_done)  state <= IDLE;
                        2'b11: if (i2c_done)  state <= IDLE;
                    endcase
                end

            endcase
        end
    end

endmodule
