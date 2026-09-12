`timescale 1ns/1ps

module cpu8_tb;
    logic clk = 1'b0;
    logic reset;
    logic [7:0] out_port;
    logic out_strobe;
    logic halted;
    integer out_count;
    logic [2:0] test_op;
    logic [7:0] test_a;
    logic [7:0] test_b;
    logic [7:0] test_y;
    logic test_c;

    alu test_alu (
        .op(test_op),
        .a(test_a),
        .b(test_b),
        .y(test_y),
        .c(test_c)
    );

    cpu8_system #(
        .PROGRAM_FILE("tb/program.hex")
    ) dut (
        .clk(clk),
        .reset(reset),
        .out_port(out_port),
        .out_strobe(out_strobe),
        .halted(halted)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (out_strobe) begin
            case (out_count)
                0: if (out_port !== 8'h37)
                    $fatal(1, "Feil sum: %02h", out_port);
                1: if (out_port !== 8'h00)
                    $fatal(1, "Carry-hopp feilet: %02h", out_port);
                default: $fatal(1, "For mange OUT-instruksjoner");
            endcase
            out_count <= out_count + 1;
        end
    end

    initial begin
        reset = 1'b1;
        out_count = 0;

        // Prov alle ALU-valgene.
        test_a = 8'h55;
        test_b = 8'h0f;
        test_op = 3'd2; #1;
        if (test_y !== 8'h05) $fatal(1, "AND feilet");
        test_op = 3'd3; #1;
        if (test_y !== 8'h5f) $fatal(1, "OR feilet");
        test_op = 3'd4; #1;
        if (test_y !== 8'h5a) $fatal(1, "XOR feilet");
        test_a = 8'h03;
        test_b = 8'h05;
        test_op = 3'd1; #1;
        if (test_y !== 8'hfe || test_c !== 1'b0)
            $fatal(1, "SUB feilet");

        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        fork
            begin
                wait (halted);
                @(posedge clk);

                if (out_count !== 2)
                    $fatal(1, "Forventet 2 utdata, fikk %0d", out_count);
                if (dut.ram.mem[8'hf0] !== 8'h37)
                    $fatal(1, "RAM-test feilet");

                $display("PASS: CPU test completed");
                $finish;
            end
            begin
                repeat (500) @(posedge clk);
                $fatal(1, "CPU stoppet ikke");
            end
        join_any
    end
endmodule