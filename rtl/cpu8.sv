module cpu8 (
    input logic clk,
    input logic reset,

    output logic [7:0] rom_addr,
    input logic [7:0] rom_data,

    output logic [7:0] mem_addr,
    output logic [7:0] mem_din,
    output logic mem_wr,
    input logic [7:0] mem_dout,

    output logic [7:0] out_port,
    output logic out_strobe,
    output logic halted
);
    typedef enum logic [1:0] {
        S_FETCH,
        S_ARG,
        S_RUN
    } state_t;

    localparam logic [7:0] NOP = 8'h00;
    localparam logic [7:0] LDI = 8'h10;
    localparam logic [7:0] LDA = 8'h11;
    localparam logic [7:0] STA = 8'h12;
    localparam logic [7:0] ADD = 8'h20;
    localparam logic [7:0] SUB = 8'h21;
    localparam logic [7:0] AND = 8'h22;
    localparam logic [7:0] ORR = 8'h23;
    localparam logic [7:0] XOR = 8'h24;
    localparam logic [7:0] ADI = 8'h25;
    localparam logic [7:0] JMP = 8'h30;
    localparam logic [7:0] JZ = 8'h31;
    localparam logic [7:0] JC = 8'h32;
    localparam logic [7:0] OUT = 8'h40;
    localparam logic [7:0] HLT = 8'hff;

    state_t state;
    logic [7:0] pc;
    logic [7:0] acc;
    logic [7:0] ir;
    logic [7:0] arg;
    logic z;
    logic c;

    logic [2:0] alu_op;
    logic [7:0] alu_b;
    logic [7:0] alu_y;
    logic alu_c;

    // Velg det ALU-en skal gjore.
    always_comb begin
        alu_op = 3'd0;
        alu_b = mem_dout;

        case (ir)
            SUB: alu_op = 3'd1;
            AND: alu_op = 3'd2;
            ORR: alu_op = 3'd3;
            XOR: alu_op = 3'd4;
            ADI: alu_b = arg;
            default: begin end
        endcase
    end

    alu u_alu (
        .op(alu_op),
        .a(acc),
        .b(alu_b),
        .y(alu_y),
        .c(alu_c)
    );

    assign rom_addr = pc;
    assign mem_addr = arg;
    assign mem_din = acc;

    // RAM skrives bare i denne tilstanden.
    always_comb begin
        mem_wr = 1'b0;
        if (state == S_RUN && ir == STA)
            mem_wr = 1'b1;
    end

    function automatic logic has_arg(input logic [7:0] op);
        case (op)
            LDI, LDA, STA, ADD, SUB, AND, ORR, XOR,
            ADI, JMP, JZ, JC: has_arg = 1'b1;
            default: has_arg = 1'b0;
        endcase
    endfunction

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= S_FETCH;
            pc <= 8'h00;
            acc <= 8'h00;
            ir <= NOP;
            arg <= 8'h00;
            z <= 1'b1;
            c <= 1'b0;
            out_port <= 8'h00;
            out_strobe <= 1'b0;
            halted <= 1'b0;
        end else begin
            out_strobe <= 1'b0;

            if (!halted) begin
                case (state)
                    S_FETCH: begin
                        ir <= rom_data;
                        pc <= pc + 8'd1;

                        if (has_arg(rom_data))
                            state <= S_ARG;
                        else
                            state <= S_RUN;
                    end

                    S_ARG: begin
                        arg <= rom_data;
                        pc <= pc + 8'd1;
                        state <= S_RUN;
                    end

                    S_RUN: begin
                        case (ir)
                            LDI: begin
                                acc <= arg;
                                z <= (arg == 8'h00);
                                c <= 1'b0;
                            end
                            LDA: begin
                                acc <= mem_dout;
                                z <= (mem_dout == 8'h00);
                            end
                            ADD, SUB, AND, ORR, XOR, ADI: begin
                                acc <= alu_y;
                                z <= (alu_y == 8'h00);
                                c <= alu_c;
                            end
                            JMP: pc <= arg;
                            JZ: if (z) pc <= arg;
                            JC: if (c) pc <= arg;
                            OUT: begin
                                out_port <= acc;
                                out_strobe <= 1'b1;
                            end
                            HLT: halted <= 1'b1;
                            default: begin end
                        endcase

                        state <= S_FETCH;
                    end

                    default: state <= S_FETCH;
                endcase
            end
        end
    end
endmodule