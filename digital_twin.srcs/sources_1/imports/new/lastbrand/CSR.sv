module CSR #(
    parameter   DATAWIDTH = 32	
)(
	input  logic 					clk			,
	input  logic 					rst			,
	input  logic [DATAWIDTH-1:0]	pc			,
	input  logic [DATAWIDTH-1:0]	rf1			,
	input  logic [11:0] 			csr_idx		,
	input  logic [3:0]  			CSRControll	,

	output logic [DATAWIDTH-1:0] 	csr_npc		,
	output logic [DATAWIDTH-1:0]	csr_wb
);

	// CSR寄存器
	reg [DATAWIDTH-1:0] mstatus, mepc, mtvec, mcause;
	reg [DATAWIDTH-1:0] mie, mscratch, mip;

	// old备份值
	reg [DATAWIDTH-1:0] old_mstatus, old_mepc, old_mtvec, old_mcause;
	reg [DATAWIDTH-1:0] old_mie, old_mscratch, old_mip;

	reg [DATAWIDTH-1:0] mask;

	// 初始化mask
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mask <= 32'hFFFFFFFF;
		end
	end

	// old寄存器备份
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			old_mstatus <= 0;
			old_mepc    <= 0;
			old_mtvec   <= 0;
			old_mcause  <= 0;
			old_mie     <= 0;
			old_mscratch<= 0;
			old_mip     <= 0;
		end else begin
			old_mstatus <= mstatus;
			old_mepc    <= mepc;
			old_mtvec   <= mtvec;
			old_mcause  <= mcause;
			old_mie     <= mie;
			old_mscratch<= mscratch;
			old_mip     <= mip;
		end
	end

	// mstatus更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mstatus <= 32'h1800;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h300) mstatus <= mask & (old_mstatus | rf1);
				4'b0010: if (csr_idx == 12'h300) mstatus <= mask & rf1;
				4'b0100: mstatus <= { old_mstatus[31:8], old_mstatus[3], old_mstatus[6:4], old_mstatus[2:0] }; // MRET 恢复
				4'b1000: mstatus <= { old_mstatus[31:13], 2'b11, old_mstatus[10:8], 1'b1, old_mstatus[6:4], old_mstatus[3], old_mstatus[2:0] }; // ECALL
				default: mstatus <= mstatus;
			endcase
		end
	end

	// mie更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mie <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h304) mie <= old_mie | rf1;
				4'b0010: if (csr_idx == 12'h304) mie <= rf1;
				default: mie <= mie;
			endcase
		end
	end

	// mtvec更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mtvec <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h305) mtvec <= old_mtvec | rf1;
				4'b0010: if (csr_idx == 12'h305) mtvec <= rf1;
				default: mtvec <= mtvec;
			endcase
		end
	end

	// mscratch更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mscratch <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h340) mscratch <= old_mscratch | rf1;
				4'b0010: if (csr_idx == 12'h340) mscratch <= rf1;
				default: mscratch <= mscratch;
			endcase
		end
	end

	// mepc更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mepc <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h341) mepc <= old_mepc | rf1;
				4'b0010: if (csr_idx == 12'h341) mepc <= rf1;
				4'b0100: mepc <= pc; // trap保存当前PC
				default: mepc <= mepc;
			endcase
		end
	end

	// mcause更新
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mcause <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h342) mcause <= old_mcause | rf1;
				4'b0010: if (csr_idx == 12'h342) mcause <= rf1;
				4'b0100: mcause <= 32'h0b;  // ECALL from M-mode
				default: mcause <= mcause;
			endcase
		end
	end

	// mip更新（可写，用于测试）
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mip <= 0;
		end else begin
			case (CSRControll)
				4'b0001: if (csr_idx == 12'h344) mip <= old_mip | rf1;
				4'b0010: if (csr_idx == 12'h344) mip <= rf1;
				default: mip <= mip;
			endcase
		end
	end

	// CSR读取结果
	assign csr_wb = 
		{32{csr_idx == 12'h300}} & old_mstatus  |
		{32{csr_idx == 12'h304}} & old_mie      |
		{32{csr_idx == 12'h305}} & old_mtvec    |
		{32{csr_idx == 12'h340}} & old_mscratch |
		{32{csr_idx == 12'h341}} & old_mepc     |
		{32{csr_idx == 12'h342}} & old_mcause   |
		{32{csr_idx == 12'h344}} & old_mip;

	// CSR跳转地址（MRET或异常）
	assign csr_npc =
		{32{CSRControll == 4'b0100}} & old_mtvec |
		{32{CSRControll == 4'b1000}} & old_mepc;

endmodule
