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
