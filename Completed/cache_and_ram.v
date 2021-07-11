module cache_and_ram(
	// address是原始内存ram的地址
	// 整个地址被分成两部分，ram的index右移掉cache的index位和cache的index位组成的
	// tag + index != adress
	// tag = address >> index.length
	// 每个cache line都有对应唯一index，可能有相同的tag，但是tag+index一定是唯一的
	// 知道地址（其实就是ram的地址）和cache的length，可以求得tag、cache的index
	// 知道cache的地址（index、tag），无法求得ram的地址
	input [31:0] address,
	input [31:0] data,
	input clk,
	input mode,	//mode equal to 1 when we write and equal to 0 when we read
	output [31:0] out
);

//previous values
// 地址是31位的，index+tag是12位
//
reg [31:0] prev_address, prev_data;
reg prev_mode;
reg [31:0] temp_out;
// 设置跟cache的index
reg [cache.index_size - 1:0] index;	// for keeping index of current address
// 设置cache的tag
reg [11 - cache.index_size:0] tag;	// for keeping tag of ceurrent address
// 4k个32位内存，共16KB内存，需要9位才能完整表示地址
ram ram();
// 64个32位cache line，相当于1/64的ram
cache cache();

initial
	begin
		index = 0;
		tag = 0;
		prev_address = 0;
		prev_data = 0;
		prev_mode = 0;
	end

always @(posedge clk)
begin
	//check if the new input is updated
	// 如果地址、数据或者读写模式变更
	if (prev_address != address || prev_data != data || prev_mode != mode)
		begin
			// 地址取余，分配新的地址（index），其实就是取得真正的ram地址
			// 余数小于4096（刚好12位），即ram的地址需要12位才能表达完
			prev_address = address % ram.size;
			prev_data = data;
			// 设置模式
			prev_mode = mode;
			// ram内存地址 右移掉cache line index需要的位数就是tag的值
			tag = prev_address >> cache.index_size;	// tag = first bits of address except index ones (In our particular case - 6)
			// 获取cache的地址
			index = address % cache.size; 		// index value = last n (n = size of cache) bits of address
			// 写模式，同时写入ram和cache
			if (mode == 1)
				begin
					// 根据ram index写入数据
					ram.ram[prev_address] = data;
					//write new data to the relevant cache block if there is such one
					// 如果cache line是有效的，且cache line的tag跟目标地址的tag相等则写入数据
					// 写操作时，如果cache line有效，且命中cache line（index和tag都一样），写同步写入cache line
					if (cache.valid_array[index] == 1 && cache.tag_array[index] == tag)
						// 将数据同步写入cache
						cache.cache[index] = data;
				end
			else
			// 读模式，同时将数据同步到cache
				begin
					//write new data to the relevant cache's block, because the one we addressing to will be possibly addressed one more time soon
					// 如果cache line无效或者tag不等，则将ram的数据同步到cache
					// 读操作时，如果该cache line已失效，或者命中的该cache line而cache line的数据落后了，则更新同步更新cache
					if (cache.valid_array[index] != 1 || cache.tag_array[index] != tag)
						begin
							cache.valid_array[index] = 1;
							cache.tag_array[index] = tag;
							cache.cache[index] = ram.ram[prev_address];
						end
					temp_out = cache.cache[index];
				end	
		end
end

assign out = temp_out;

endmodule 
