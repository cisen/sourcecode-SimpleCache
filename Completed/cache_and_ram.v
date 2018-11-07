module cache_and_ram(
	input [31:0] address,
	input [31:0] data,
	input clk,
	input mode,
	output [31:0] out
);

//previous values
reg [31:0] prev_address, prev_data;
reg prev_mode;
reg [31:0] temp_out;

reg [cache.index_size - 1:0] index;	// for keeping index of current address
reg [11 - cache.index_size:0] tag;	// for keeping tag of ceurrent address

ram ram();
cache cache();

initial
	begin
		index = 0;
		tag = 0;
		prev_address = 0;
		prev_data = 0;
		prev_mode = 0;
	end

always @(edge clk)
begin
	//
	if (prev_address != address || prev_data != data || prev_mode != mode)
		begin
			prev_address = address % ram.size;
			prev_data = data;
			prev_mode = mode;
			
			tag = prev_address >> cache.index_size;	//
			index = address % cache.size; 		//
				
			if (mode == 1)
				begin
					ram.ram[prev_address] = data;
					//
					if (cache.valid_array[index] == 1 && cache.tag_array[index] == tag)
						cache.cache[index] = data;
				end
			else
				begin
					//
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