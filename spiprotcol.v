`timescale 1ns/1ps

module spi_master (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [7:0] data_in,
    output reg MOSI,
    output reg SCLK,
    output reg SS,
    output reg done
);

reg [2:0] bit_cnt;
reg [7:0] shift_reg;
reg state;

parameter IDLE = 1'b0, TRANSFER = 1'b1;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        MOSI <= 0;
        SCLK <= 0;
        SS <= 1;
        done <= 0;
        bit_cnt <= 0;
        state <= IDLE;
    end else begin
        case(state)

        IDLE: begin
            SS <= 1;
            done <= 0;
            SCLK <= 0;

            if (start) begin
                shift_reg <= data_in;
                bit_cnt <= 7;
                SS <= 0;
                state <= TRANSFER;
            end
        end

        TRANSFER: begin
            SCLK <= ~SCLK;

            if (SCLK == 0) begin
                MOSI <= shift_reg[7];
                shift_reg <= shift_reg << 1;

                if (bit_cnt == 0) begin
                    SS <= 1;
                    done <= 1;
                    state <= IDLE;
                end else begin
                    bit_cnt <= bit_cnt - 1;
                end
            end
        end

        endcase
    end
end

endmodule


// ================= SPI SLAVE =================
module spi_slave (
    input wire SCLK,
    input wire reset,
    input wire SS,
    input wire MOSI,
    output reg [7:0] data_out,
    output reg done
);

reg [7:0] shift_reg;
reg [2:0] bit_cnt;

always @(negedge SCLK or posedge reset) begin
    if (reset) begin
        shift_reg <= 0;
        data_out <= 0;
        bit_cnt <= 0;
        done <= 0;
    end else if (!SS) begin
        shift_reg <= {shift_reg[6:0], MOSI};
        bit_cnt <= bit_cnt + 1;

        if (bit_cnt == 7) begin
            data_out <= {shift_reg[6:0], MOSI};
            done <= 1;
            bit_cnt <= 0;
        end else begin
            done <= 0;
        end
    end
end

endmodule