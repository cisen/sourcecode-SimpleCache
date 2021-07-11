module ram();

parameter size = 4096; //size of a ram in bits
// 4096个32位的ram，这里模拟内存
reg [31:0] ram [0:size-1]; //data matrix for ram

endmodule
