`timescale 1ns/1ps

module tb_spi;

reg clk;
reg reset;
reg start;
reg [7:0] data_in;

wire MOSI;
wire SCLK;
wire SS;
wire done_master;
wire [7:0] data_out;
wire done_slave;

// ================= DUT INSTANCES =================
spi_master master (
    .clk(clk),
    .reset(reset),
    .start(start),
    .data_in(data_in),
    .MOSI(MOSI),
    .SCLK(SCLK),
    .SS(SS),
    .done(done_master)
);

spi_slave slave (
    .SCLK(SCLK),
    .reset(reset),
    .SS(SS),
    .MOSI(MOSI),
    .data_out(data_out),
    .done(done_slave)
);

// ================= CLOCK GENERATION =================
always #5 clk = ~clk;   // 100 MHz equivalent

// ================= STIMULUS =================
initial begin
    $dumpfile("spi.vcd");
    $dumpvars(0, tb_spi);

    // Initialize signals
    clk = 0;
    reset = 1;
    start = 0;
    data_in = 8'hA5;   // test data (10100101)

    // Apply reset
    #20 reset = 0;

    // Start SPI transfer
    #20 start = 1;
    #10 start = 0;

    // Wait for transfer to complete
    #200;

    // Display results
    $display("=================================");
    $display("MASTER DONE  : %b", done_master);
    $display("SLAVE DONE   : %b", done_slave);
    $display("RECEIVED DATA: %h", data_out);
    $display("=================================");

    $finish;
end

endmodule