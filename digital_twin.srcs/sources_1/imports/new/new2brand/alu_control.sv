module alu_control(
    input  logic [6:0] opcode,
    input  logic [3:0] funct,
    output logic [3:0] ALUControl,
    output logic       isBranch    // 新增输出
);

    always_comb begin
        ALUControl = 4'b0000;
        isBranch   = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                case (funct)
                    4'b0000: ALUControl = 4'b0000; // ADD
                    4'b1000: ALUControl = 4'b0001; // SUB
                    4'b0111: ALUControl = 4'b0010; // AND
                    4'b0110: ALUControl = 4'b0011; // OR
                    4'b0100: ALUControl = 4'b0100; // XOR
                    4'b0001: ALUControl = 4'b0101; // SLL
                    4'b0101: ALUControl = 4'b0110; // SRL
                    4'b1101: ALUControl = 4'b0111; // SRA
                    4'b0010: ALUControl = 4'b1000; // SLT
                    4'b0011: ALUControl = 4'b1001; // SLTU
                endcase
            end

            7'b0010011: begin // I-type
                case (funct[2:0])
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                endcase
                case (funct)
                    4'b0001: ALUControl = 4'b0101; // SLLI
                    4'b0101: ALUControl = 4'b0110; // SRLI
                    4'b1101: ALUControl = 4'b0111; // SRAI
                endcase
            end

            7'b1100111: begin // JALR
                ALUControl = 4'b0000;
            end

            7'b1100011: begin // B-type
                isBranch   = 1'b1; // 标记为分支指令
                case (funct[2:0])
                    3'b000: ALUControl = 4'b1000; // BEQ
                    3'b001: ALUControl = 4'b1001; // BNE
                    3'b100: ALUControl = 4'b1010; // BLT
                    3'b101: ALUControl = 4'b1011; // BGE
                    3'b110: ALUControl = 4'b1100; // BLTU
                    3'b111: ALUControl = 4'b1101; // BGEU
                endcase
            end

            7'b0110111 :begin
                ALUControl = 4'b1111;
            end

            default: begin
                ALUControl = 4'b0000;
                isBranch   = 1'b0;
            end
        endcase
    end

endmodule
