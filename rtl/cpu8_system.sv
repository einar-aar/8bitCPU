module cpu8_system #(
    parameter PROGRAM_FILE = "program.hex"
) (
    input logic clk,
    input logic reset,
    output logic [7:0] out_port,
    output logic out_strobe,
    output logic halted
);
    logic [7:0] rom_addr;
    logic [7:0] rom_data;
    logic [7:0] mem_addr;
    logic [7:0] mem_din;
    logic [7:0] mem_dout;
    logic mem_wr;

    program_rom #(.FILE(PROGRAM_FILE)) rom (
        .addr(rom_addr),
        .data(rom_data)
    );

    data_ram ram (
        .clk(clk),
        .addr(mem_addr),
        .din(mem_din),
        .wr(mem_wr),
        .dout(mem_dout)
    );

    cpu8 cpu (
        .clk(clk),
        .reset(reset),
        .rom_addr(rom_addr),
        .rom_data(rom_data),
        .mem_addr(mem_addr),
        .mem_din(mem_din),
        .mem_wr(mem_wr),
        .mem_dout(mem_dout),
        .out_port(out_port),
        .out_strobe(out_strobe),
        .halted(halted)
    );
endmodule