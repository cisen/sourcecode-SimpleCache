module cache_no_mode_clever(
	
	input [31:0] address,	//

	input clk,		//
	
	output response,	// 0 - cache finished writing or reading, 1 - cache busy
	
	output [31:0] out	//
);

parameter size = 64;		// cache size
parameter index_size = 6;	// index size
parameter size_ram = 4096;	// ram size

//
reg [31:0] cache [0:size - 1];
reg [index_size - 1:0] index;	// for keeping index of current address
reg [11 - index_size:0] tag;	// for keeping tag of ceurrent address
reg [11 - index_size:0] tag_array [0:size - 1]; // for all tags in cache
reg valid_array [0:size - 1]; //0 - there is no data 1 - there is data

//initialization for valid_array and tag_array for using in ram_clever
initial
	begin: initialization
		integer i;
		for (i = 0; i < size; i = i + 1)
		begin
			valid_array[i] = 6'b000000;
			tag_array[i] = 6'b000000;
		end
	end

//previous values
reg [31:0] prev_address;
reg [31:0] temp_out;
reg prev_response;

//
initial
	begin
		prev_address = 	0;
		prev_response = 0;
	end

//
reg [31:0] data_ram, address_ram;
reg mode_ram;
wire [31:0] out_ram;
wire response_ram;

ram_clever ram(
	.data(data_ram),
	.address(address_ram),
	.clk(clk),
	.mode(mode_ram),
	.out(out_ram),
	.response(response_ram)
);

//
always @(negedge clk)
	begin
		//
		if (prev_address != address % size_ram)
			begin
				prev_address = address % size_ram;
				prev_response = 1;
	
				tag = prev_address >> index_size;	//
				index = prev_address % index_size; 	//
				
				//
				if (valid_array[index] == 1 && tag_array[index] == tag)
					begin
						//no_missrate
						temp_out = cache[index];
						prev_response = 0;
					end
				else
					begin
						//missrate
						data_ram = 0;
						address_ram = address;
						mode_ram = 0;					
					end
			end
		else
			//
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