module program_rom #(
    parameter FILE = "program.hex"
) (
    input logic [7:0] addr,
    output logic [7:0] data
);
    logic [7:0] mem [0:255];

    initial begin
        for (integer i = 0; i < 256; i = i + 1)
            mem[i] = 8'h00;
        $readmemh(FILE, mem);
    end

    assign data = mem[addr];
endmodule