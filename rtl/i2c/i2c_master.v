module i2c_master (
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire [6:0] slave_addr,
    input  wire [7:0] write_data,

    output reg  busy,
    output reg  done,
    output reg  ack_error,

    inout  wire sda,
    inout  wire scl
);

    // ------------------------------------------------
    // Open drain
    // ------------------------------------------------
    reg sda_low, scl_low;
    assign sda = sda_low ? 1'b0 : 1'bz;
    assign scl = scl_low ? 1'b0 : 1'bz;
    wire sda_in = sda;

    // ------------------------------------------------
    // Clock divider (slow down simulation)
    // ------------------------------------------------
    reg [7:0] div_cnt;
    wire tick = (div_cnt == 1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            div_cnt <= 0;
        else if (tick)
            div_cnt <= 0;
        else
            div_cnt <= div_cnt + 1;
    end

    // ------------------------------------------------
    // FSM
    // ------------------------------------------------
    localparam IDLE       = 0,
               START_ST   = 1,
               SEND_ADDR  = 2,
               ACK1       = 3,
               SEND_DATA  = 4,
               ACK2       = 5,
               STOP_ST    = 6,
               DONE_ST    = 7;

    reg [2:0] state;
    reg [7:0] shift;
    reg [3:0] bit_cnt;
    reg       scl_phase;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            sda_low   <= 0;
            scl_low   <= 0;
            busy      <= 0;
            done      <= 0;
            ack_error <= 0;
            bit_cnt   <= 0;
            scl_phase <= 0;
        end else begin
            done <= 0;

            if (tick) begin
                case (state)

                // ---------------- IDLE ----------------
                IDLE: begin
                    busy    <= 0;
                    sda_low <= 0;
                    scl_low <= 0;
                    ack_error <= 0;

                    if (start) begin
                        busy    <= 1;
                        shift   <= {slave_addr,1'b0}; // write
                        bit_cnt <= 7;
                        state   <= START_ST;
                    end
                end

                // ---------------- START ----------------
                START_ST: begin
                    sda_low   <= 1;   // SDA ↓
                    scl_low   <= 0;   // SCL high
                    scl_phase <= 0;
                    state     <= SEND_ADDR;
                end

                // ---------------- SEND ADDRESS ----------------
                SEND_ADDR: begin
                    if (scl_phase == 0) begin
                        scl_low   <= 1;
                        sda_low   <= ~shift[bit_cnt];
                        scl_phase <= 1;
                    end else begin
                        scl_low   <= 0;
                        scl_phase <= 0;

                        if (bit_cnt == 0)
                            state <= ACK1;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                // ---------------- ACK1 ----------------
                ACK1: begin
                    if (scl_phase == 0) begin
                        scl_low   <= 1;
                        sda_low   <= 0;  // release
                        scl_phase <= 1;
                    end else begin
                        scl_low   <= 0;
                        ack_error <= sda_in;
                        scl_phase <= 0;

                        // load DATA
                        shift   <= write_data;
                        bit_cnt <= 7;
                        state   <= SEND_DATA;
                    end
                end

                // ---------------- SEND DATA ----------------
                SEND_DATA: begin
                    if (scl_phase == 0) begin
                        scl_low   <= 1;
                        sda_low   <= ~shift[bit_cnt];
                        scl_phase <= 1;
                    end else begin
                        scl_low   <= 0;
                        scl_phase <= 0;

                        if (bit_cnt == 0)
                            state <= ACK2;
                        else
                            bit_cnt <= bit_cnt - 1;
                    end
                end

                // ---------------- ACK2 ----------------
                ACK2: begin
                    if (scl_phase == 0) begin
                        scl_low   <= 1;
                        sda_low   <= 0;
                        scl_phase <= 1;
                    end else begin
                        scl_low   <= 0;
                        scl_phase <= 0;
                        state <= STOP_ST;
                    end
                end

                // ---------------- STOP ----------------
                STOP_ST: begin
                    sda_low <= 0;
                    scl_low <= 0;
                    state   <= DONE_ST;
                end

                // ---------------- DONE ----------------
                DONE_ST: begin
                    busy <= 0;
                    done <= 1;
                    state <= IDLE;
                end

                endcase
            end
        end
    end

endmodule
