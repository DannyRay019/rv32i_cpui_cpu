


module alu#(
    parameter   DATAWIDTH = 32	
)(
    input  logic [DATAWIDTH - 1:0]  A           ,
    input  logic [DATAWIDTH - 1:0]  B           ,
    input  logic [3:0]              ALUControl  ,
    input  logic     [2:0]          isBranch    ,
    output logic [DATAWIDTH - 1:0]  Result      ,
    output logic                    is_True        
);
    logic [DATAWIDTH-1:0] add_result, sub_result;
    logic [DATAWIDTH-1:0] and_result, or_result, xor_result;
    logic [DATAWIDTH-1:0] sll_result, srl_result, sra_result;
    logic cout_add, cout_sub;

    // 加法运算
    adder_alu #(.DATAWIDTH(DATAWIDTH)) adder (
        .a(A),
        .b(B),
        .sum(add_result),
        .cout1(cout_add)
    );

    // 减法运算
    sub_alu #(.DATAWIDTH(DATAWIDTH)) sub (
        .a(A),
        .b(B),
        .diff(sub_result),
        .cout2(cout_sub)
    );

    // 逻辑运算
    assign and_result = A & B;
    assign or_result  = A | B;
    assign xor_result = A ^ B;

    // 移位运算
    assign sll_result = A << B[4:0];  // 逻辑左移
    assign srl_result = A >> B[4:0];  // 逻辑右移
    assign sra_result = $signed(A) >>> B[4:0];  // 算术右移（保留符号位）

    
    // 分支比较
    always_comb begin
        is_True = 1'b0;  // 默认赋值，防止锁存器

        if (isBranch == 3'b010) begin
            case (ALUControl)
                4'b1000: is_True = (A == B);          // BEQ
                4'b1001: is_True = (A != B);          // BNE
                4'b1010: is_True = ($signed(A) < $signed(B));  // BLT
                4'b1011: is_True = ($signed(A) >= $signed(B)); // BGE
                4'b1100: is_True = (A < B);           // BLTU
                4'b1101: is_True = (A >= B);          // BGEU
                default: is_True = 1'b0;
            endcase
        end
    end


    // ALU 运算结果选择
    always_comb begin
        case (ALUControl)
            4'b0000: Result = add_result;  // ADD / ADDI / JALR
            4'b0001: Result = sub_result;  // SUB
            4'b0010: Result = and_result; // AND / ANDI
            4'b0011: Result = or_result;  // OR / ORI
            4'b0100: Result = xor_result; // XOR / XORI
            4'b0101: Result = sll_result; // SLL / SLLI
            4'b0110: Result = srl_result; // SRL / SRLI
            4'b0111: Result = sra_result; // SRA / SRAI
            4'b1000: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;  // SLT
            4'b1001: Result = (A < B) ? 32'd1 : 32'd0;  
            4'b1111: Result = B;
            default: Result = 32'b0;  // 默认输出 0
        endcase
    end

endmodule


module adder_alu#(
    parameter DATAWIDTH = 32
)(
    input  logic [DATAWIDTH-1:0] a,
    input  logic [DATAWIDTH-1:0] b,
    output logic [DATAWIDTH-1:0] sum,
    output logic cout1
);
    /* verilator lint_off UNOPTFLAT */
    logic [DATAWIDTH:0] carry;
    /* verilator lint_on UNOPTFLAT */
    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < DATAWIDTH; i++) begin : adder_loop
            adder_single u_adder (
                .a   (a[i]),
                .b   (b[i]),
                .cin (carry[i]),
                .sum (sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
    assign cout1 = carry[DATAWIDTH];
endmodule

module sub_alu#(
    parameter  DATAWIDTH = 32
)(
    input  logic [DATAWIDTH-1:0] a,
    input  logic [DATAWIDTH-1:0] b,
    output logic [DATAWIDTH-1:0] diff,
    output logic cout2      
);
    logic [DATAWIDTH-1:0] b_ff;
    logic [DATAWIDTH:0] result;
    localparam logic [DATAWIDTH-1:0] ONE = {{DATAWIDTH-1{1'b0}}, 1'b1};

    adder_alu #(.DATAWIDTH(DATAWIDTH)) p1 (
        .a(~b),
        .b(ONE),
        .sum(b_ff),
        .cout1(result[DATAWIDTH])
    );
    adder_alu p2(
        .a(a),
        .b(b_ff),
        .sum(result[DATAWIDTH-1:0]),
        .cout1(result[DATAWIDTH])
    );
    assign diff = result[DATAWIDTH-1:0];
    assign cout2 = result[DATAWIDTH];
endmodule 

module adder#(
    parameter   DATAWIDTH = 32
)(
    input  logic [DATAWIDTH - 1:0] A          ,
    input  logic [DATAWIDTH - 1:0] B          ,
    output logic [DATAWIDTH - 1:0] Result     
);
    /* verilator lint_off UNOPTFLAT */
    logic [DATAWIDTH:0] carry;
    /* verilator lint_on UNOPTFLAT */
    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < DATAWIDTH; i++) begin : adder_loop
            adder_single u_adder (
                .a   (A[i]),
                .b   (B[i]),
                .cin (carry[i]),
                .sum (Result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
endmodule

module adder_single(
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
logic s1;
logic c1;
logic s2;
logic c2;
adder_half p1(
    .a(a),
    .b(b),
    .s(s1),
    .c(c1)
);

adder_half p2(
    .a(s1),
    .b(cin),
    .s(s2),
    .c(c2)
);
assign sum=s2;
assign cout=c1|c2;

endmodule

module  adder_half(
    input logic a,
    input logic b,
    output logic s,
    output logic c
);
assign s=a^b;
assign c=a&b;

endmodule
