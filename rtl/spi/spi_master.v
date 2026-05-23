module spi_master #
(
    parameter CLK_DIV = 499
)
(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] data_in,
    input  wire [1:0] mode,

    output reg  [7:0] data_out,
    output reg        busy,
    output reg        done,

    output reg        cs_n,
    output wire       sclk,
    output reg        mosi,
    input  wire       miso
);

wire cpol = mode[1];
wire cpha = mode[0];

localparam S_IDLE  = 0;
localparam S_SHIFT = 1;
localparam S_DONE  = 2;

reg [1:0] state;

reg [7:0] shft_tx;
reg [7:0] shft_rx;

reg [2:0] bit_idx;
reg [15:0] clk_cnt;
reg sclk_int;

assign sclk = cpol ? ~sclk_int : sclk_int;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        clk_cnt  <= 0;
        sclk_int <= cpol;
    end
    else if(busy) begin
        if(clk_cnt == CLK_DIV-1) begin
            clk_cnt <= 0;
            sclk_int <= ~sclk_int;
        end
        else
            clk_cnt <= clk_cnt + 1;
    end
    else begin
        clk_cnt  <= 0;
        sclk_int <= cpol;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        state    <= S_IDLE;
        cs_n     <= 1;
        busy     <= 0;
        done     <= 0;
        bit_idx  <= 0;
        mosi     <= 0;
        shft_tx  <= 0;
        shft_rx  <= 0;
        data_out <= 0;
    end
    else begin
        done <= 0;

        case(state)

        S_IDLE:
        begin
            cs_n <= 1;
            busy <= 0;

            if(start) begin
                cs_n    <= 0;
                busy    <= 1;
                shft_tx <= data_in;
                shft_rx <= 0;
                bit_idx <= 7;
                mosi    <= data_in[7];
                state   <= S_SHIFT;
            end
        end

        S_SHIFT:
        begin
            if(clk_cnt == 0) begin

                if(sclk_int == (cpha ? 0 : 1))
                    shft_rx[bit_idx] <= miso;

                if(sclk_int == (cpha ? 1 : 0)) begin
                    if(bit_idx == 0)
                        state <= S_DONE;
                    else begin
                        bit_idx <= bit_idx - 1;
                        mosi <= shft_tx[bit_idx-1];
                    end
                end
            end
        end

        S_DONE:
        begin
            cs_n     <= 1;
            busy     <= 0;
            data_out <= shft_rx;
            done     <= 1;
            state    <= S_IDLE;
        end

        endcase
    end
end

endmodule