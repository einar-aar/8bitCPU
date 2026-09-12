module alu (
    input logic [2:0] op,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] y,
    output logic c
);
    logic [8:0] tmp;

    always_comb begin
        y = 8'h00;
        c = 1'b0;
        tmp = 9'h000;

        case (op)
            3'd0: begin
                tmp = {1'b0, a} + {1'b0, b};
                y = tmp[7:0];
                c = tmp[8];
            end
            3'd1: begin
                tmp = {1'b0, a} - {1'b0, b};
                y = tmp[7:0];
                c = ~tmp[8];
            end
            3'd2: y = a & b;
            3'd3: y = a | b;
            3'd4: y = a ^ b;
            default: y = b;
        endcase
    end
endmodule