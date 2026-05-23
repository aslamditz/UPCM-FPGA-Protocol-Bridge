module uart_tx

#(

    parameter CLKS_PER_BIT = 8  // adjust based on your clock & baud

)

(

    input  wire       i_clk,

    input  wire       i_rst,      // async reset, active high

    input  wire       i_start,    // pulse high to start transmission

    input  wire [7:0] i_data,     // data byte to send



    output reg        o_tx,       // UART TX line

    output reg        o_busy,     // high while transmitting

    output reg        o_done      // 1-clock pulse when frame finished

);



    // State encoding

    localparam S_IDLE      = 3'd0;

    localparam S_START_BIT = 3'd1;

    localparam S_DATA_BITS = 3'd2;

    localparam S_STOP_BIT  = 3'd3;

    localparam S_CLEANUP   = 3'd4;



    reg [2:0] state;

    reg [2:0] bit_index;          // 0-7

    reg [15:0] clk_count;         // supports wide CLKS_PER_BIT; increase if needed

    reg [7:0] data_reg;



    always @(posedge i_clk or negedge i_rst) begin

        if (!i_rst) begin

            state     <= S_IDLE;

            o_tx      <= 1'b1;    // idle line high

            o_busy    <= 1'b0;

            o_done    <= 1'b0;

            bit_index <= 3'd0;

            clk_count <= 16'd0;

            data_reg  <= 8'd0;

        end else begin

            o_done <= 1'b0;       // default



            case (state)

                S_IDLE: begin

                    o_tx   <= 1'b1;

                    o_busy <= 1'b0;

                    clk_count <= 16'd0;

                    bit_index <= 3'd0;



                    if (i_start) begin

                        // latch data and start

                        data_reg <= i_data;

                        o_busy   <= 1'b1;

                        state    <= S_START_BIT;

                    end

                end



                // Start bit (0)

                S_START_BIT: begin

                    o_tx <= 1'b0;



                    if (clk_count < (CLKS_PER_BIT - 1)) begin

                        clk_count <= clk_count + 1'b1;

                    end else begin

                        clk_count <= 16'd0;

                        state     <= S_DATA_BITS;

                    end

                end



                // Data bits (LSB first)

                S_DATA_BITS: begin

                    o_tx <= data_reg[bit_index];



                    if (clk_count < (CLKS_PER_BIT - 1)) begin

                        clk_count <= clk_count + 1'b1;

                    end else begin

                        clk_count <= 16'd0;



                        if (bit_index < 3'd7) begin

                            bit_index <= bit_index + 1'b1;

                        end else begin

                            bit_index <= 3'd0;

                            state     <= S_STOP_BIT;

                        end

                    end

                end



                // Stop bit (1)

                S_STOP_BIT: begin

                    o_tx <= 1'b1;



                    if (clk_count < (CLKS_PER_BIT - 1)) begin

                        clk_count <= clk_count + 1'b1;

                    end else begin

                        clk_count <= 16'd0;

                        state     <= S_CLEANUP;

                    end

                end



                S_CLEANUP: begin

                    o_busy <= 1'b0;

                    o_done <= 1'b1;    // 1-cycle pulse

                    state  <= S_IDLE;

                end



                default: begin

                    state <= S_IDLE;

                end

            endcase

        end

    end



endmodule

