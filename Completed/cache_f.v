module cache_f(
	
	input [31:0] data,

	input [31:0] address,

	input clk,

	input mode,

//	output missrate,
	
	output response,
	
	output [31:0] out
);

parameter size = 64;
parameter index_size = 6;
parameter size_ram = 4096;

reg [31:0] cache [size - 1:0];
reg [index_size - 1:0] index;
reg [31 - index_size:0] tag;
reg [31 - index_size:0] tag_array [size - 1:0];
reg valid_array [size - 1:0];

reg [31:0] prev_address;
reg [31:0] prev_data;
reg [31:0] temp_out;
reg prev_mode, prev_response;
//reg prev_missrate;

initial
	begin
		prev_address = 	0;
		prev_data = 0;
		prev_mode = 0;
		prev_response = 0;
//		prev_missrate = 0;
	end

reg [31:0] data_ram, address_ram;
reg mode_ram;
wire [31:0] out_ram;
wire response_ram;

ram ram(
	.data(data_ram),
	.address(address_ram),
	.clk(clk),
	.mode(mode_ram),
	.out(out_ram),
	.response(response_ram)
);

always @(negedge clk)
	begin
		if (prev_address != address % size_ram || prev_data != data || prev_mode != mode)
			begin
				prev_address = address % size_ram;
				prev_data = data;
				prev_mode = mode;
				prev_response = 1;
	
				tag = prev_address >> index_size;
				index = prev_address % index_size; 
	
				if (mode)
					begin
						cache[index] = data;
						valid_array[index] = 1;
						tag_array[index] = tag;
						prev_response = 0; 			
					end 
				else
					if (valid_array[index] == 1 && tag_array[index] == tag)
						begin
							//prev_missrate = 0;
							temp_out = cache[index];
							prev_response = 0;
						end
					else
						begin
							data_ram = data;
							address_ram = address;
							mode_ram = 0;
							//prev_missrate = 1;						
						end
			end
		else
			if (prev_response && !response_ram)
				begin
					valid_array[index] = 1;
					tag_array[index] = tag;
					cache[index] = out_ram;
					temp_out = cache[index];
					prev_response = 0;
				end	
	end

assign out = temp_out;
assign response = prev_response;
//assign missrate = prev_missrate;

endmodule 