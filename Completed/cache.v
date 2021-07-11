module cache();
// 要多少个cache line，默认64个32位的cache line
parameter size = 64;		// cache size
// 多少位宽的index才足够连接到所有的cache_line，tag跟cache一一对应，默认2^6 = 64
parameter index_size = 6;	// index size

// 64个32位的cache line，主要的数据存放地
reg [31:0] cache [0:size - 1]; //registers for the data in cache
// 12位 = 6位index_size + 6位tag
// tag_array的数量和cache是一一对应的，index用剩的位宽就留给tag，这里没有offset
reg [11 - index_size:0] tag_array [0:size - 1]; // for all tags in cache
// 每个cache line是否有效，一一对应
reg valid_array [0:size - 1]; //0 - there is no data 1 - there is data

initial
	begin: initialization
		integer i;
		for (i = 0; i < size; i = i + 1)
		begin
			valid_array[i] = 1'b0;
			tag_array[i] = 6'b000000;
		end
	end

endmodule 
