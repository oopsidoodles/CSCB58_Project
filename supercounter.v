module pulse_50000000(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [31:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 32'b00000010_11111010_11110000_01111111;
		else if (q == 32'b00000000_00000000_00000000_00000000)
			q <= 32'b00000010_11111010_11110000_01111111;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 32'b00000000_00000000_00000000_00000000) ? 1 : 0;
endmodule

module pulse_30(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [4:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 5'b11110;
		else if (q == 5'b00000)
			q <= 5'b11110;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 5'b00000) ? 1 : 0;
endmodule

module pulse_1500mill(clock, reset, enable, pulse, q, sub);
	input clock;
	input reset;
	input enable;
	output pulse;
	input sub;
	
	output reg [30:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 31'b1011001_01101000_00101111_00000000;
		else if (q == 31'b0000000_00000000_00000000_00000000) //maybe dont reset it like this?
			q <= 31'b1011001_01101000_00101111_00000000;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
		if (sub == 1'b1)
		begin
			//q <= 31'b0000000_00000000_00000000_00000000;
			if (q < 31'b0000101_11110101_11100001_00000000)
				q <= 31'b0000000_00000000_00000000_00000000;
			else
				q <= q - 31'b0000101_11110101_11100001_00000000;
		end
	end
	
	assign pulse =  (q == 31'b0000000_00000000_00000000_00000000) ? 1 : 0;
endmodule

module pulse_100mill(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [26:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 27'b101_11110101_11100000_11111111;
		else if (q == 27'b000_00000000_00000000_00000000) //maybe dont reset it like this?
			q <= 27'b101_11110101_11100000_11111111;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 27'b000_00000000_00000000_00000000) ? 1 : 0;
endmodule

module pulse_50mill(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [25:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 26'b10_11111010_11110000_01111111;
		else if (q == 26'b00_00000000_00000000_00000000) //maybe dont reset it like this?
			q <= 26'b10_11111010_11110000_01111111;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 26'b00_00000000_00000000_00000000) ? 1 : 0;
endmodule

module pulse_25mill(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [24:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 25'b1_01111101_01111000_00111111;
		else if (q == 25'b0_00000000_00000000_00000000) //maybe dont reset it like this?
			q <= 25'b1_01111101_01111000_00111111;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 25'b0_00000000_00000000_00000000) ? 1 : 0;
endmodule

module pulse_10mill(clock, reset, enable, pulse, q);
	input clock;
	input reset;
	input enable;
	output pulse;
	
	output reg [23:0] q; // declare q
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (reset == 1'b1) // when reset is 1
			q <= 24'b10011000_10010110_01111111;
		else if (q == 24'b00000000_00000000_00000000) //maybe dont reset it like this?
			q <= 24'b10011000_10010110_01111111;
		else if (enable == 1'b1)
			q <= q - 1'b1; // decrement q
	end
	
	assign pulse =  (q == 24'b00000000_00000000_00000000) ? 1 : 0;
endmodule
