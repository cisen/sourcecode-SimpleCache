module testbench;

reg [31:0] address, data;
reg mode, clk;
wire [31:0] out;

cache_and_ram tb(
	.address(address),
	.data(data),
	.mode(mode),
	.clk(clk),
	.out(out)
);

initial
begin
	// 写操作
	clk = 1'b1;
	// 往0地址写入数据
	address = 32'b00000000000000000000000000000000;			// 0
	data =    32'b00000000000000000011100011000000;			// 14528
	mode = 1'b1;
	
	#200
	// 往3036块ram写入数据，同时写入第38块cache line
	address = 32'b10100111111001011111101111011100;			// 2816867292 % size = 3036
	data =    32'b00000000000010000000100001010101;			// 526421
	mode = 1'b1;
	
	#200
	// 往2001块写数据，同时写入第17块cache line
	address = 32'b00000000000011110100011111010001;			// 1001425 % size = 2001
	data =    32'b00000001100000110001101100010110;			// 25369366
	mode = 1'b1;

	#200
	// 刷新3036的数据和cache
	address = 32'b10100111111001011111101111011100;			// 2816867292 % size = 3036
	data =    32'b00000000000000000011100011000000;			// 14528
	mode = 1'b1;

	#200
	// 刷新2001的数据和cache
	address = 32'b00000000000011110100011111010001;			// 1001425 % size = 2001
	data =    32'b00000000000000000011100011000000;			// 14528
	mode = 1'b1;

	#200
	// 读取2001的数据
	address = 32'b00000000000011110100011111010001;			// 1001425 % size = 2001
	data =    32'b00000000000000000000000000000000;			// 0
	mode = 1'b0;

	#200
	// 读取3036的数据
	address = 32'b10100111111001011111101111011100;			// 2816867292 % size = 3036
	data =    32'b00000000000000000000000000000000;			// 0
	mode = 1'b0;
		
	#200
	address = 32'b00000000000000000000000000000000;			// 0
	data =    32'b00000000000000000011100011000000;			// 14528
	mode = 1'b0;
end

initial
// ram的index，数据，读还是写，输出数据
$monitor("address = %d data = %d mode = %d out = %d", address % 4096, data, mode, out);
// 每25ns改变一次时钟值
always #25 clk = ~clk;

endmodule 
