module i2c_slave_logic #(
    parameter SLAVE_ADDR = 7'h50
)(
    input  wire clk,
    input  wire rst,

    inout  wire sda,
    inout  wire scl,

    output reg [7:0] data_out,
    output reg       data_valid,
    input  wire      data_read
);

reg sda_drive;
assign sda = (sda_drive) ? 1'b0 : 1'bz;

wire sda_in = sda;
wire scl_in = scl;

reg [7:0] shift;
reg [2:0] bit_cnt;
reg addr_phase;
reg addr_ok;

reg sda_prev;
reg scl_prev;

wire start_cond;
wire stop_cond;

assign start_cond = (sda_prev == 1 && sda_in == 0 && scl_in == 1);
assign stop_cond  = (sda_prev == 0 && sda_in == 1 && scl_in == 1);

always @(posedge clk)
begin
    sda_prev <= sda_in;
    scl_prev <= scl_in;
end

// MAIN I2C FSM
always @(posedge scl_in or posedge rst)
begin
    if(rst)
    begin
        bit_cnt <= 3'd7;
        addr_phase <= 1;
        addr_ok <= 0;
        data_valid <= 0;
    end

    else if(start_cond)
    begin
        bit_cnt <= 3'd7;
        addr_phase <= 1;
        addr_ok <= 0;
    end

    else
    begin
        shift[bit_cnt] <= sda_in;

        if(bit_cnt == 0)
        begin
            if(addr_phase)
            begin
                addr_ok <= (shift[7:1] == SLAVE_ADDR);
                addr_phase <= 0;
            end
            else
            begin
                data_out <= shift;
                data_valid <= 1;
            end

            bit_cnt <= 3'd7;
        end
        else
        begin
            bit_cnt <= bit_cnt - 1;
        end
    end
end

// ACK CONTROL
always @(posedge clk or posedge rst)
begin
    if(rst)
        sda_drive <= 0;

    else
    begin
        // ACK when address is correct
        if(addr_ok && scl_prev == 1 && scl_in == 0)
            sda_drive <= 1;

        // release SDA
        else if(scl_prev == 0 && scl_in == 1)
            sda_drive <= 0;
    end
end

// CLEAR DATA FLAG
always @(posedge clk)
begin
    if(data_read)
        data_valid <= 0;
end

endmodule