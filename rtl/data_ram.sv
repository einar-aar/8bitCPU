module data_ram (
    input logic clk,
    input logic [7:0] addr,
    input logic [7:0] din,
    input logic wr,
    output logic [7:0] dout
);
    logic [7:0] mem [0:255];

    // Lesing er direkte.
    assign dout = mem[addr];

    always_ff @(posedge clk) begin
        if (wr)
            mem[addr] <= din;
    end
endmodule