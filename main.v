module Panorama(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6);
    input [17:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [17:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6;

    wire resetn;
	wire next;
	wire go;

    wire [7:0] data_result;
    assign next = ~KEY[1];
    assign resetn = KEY[0];
	assign go = ~KEY[3];

	wire [3:0] d3;
	wire [3:0] d2;
	wire [3:0] d1;
	wire [3:0] d0;

    part2 u0(
	.clk(CLOCK_50),
	.resetn(resetn),
	.next(next),
	.go(go),
	.switches(SW[17:0]),

	.temp(LEDR[13:0]),
	.temp2(LEDR[17]),

	.d3(d3),
	.d2(d2),
	.d1(d1),
	.d0(d0)
    );

    hex_decoder H0(
        .hex_digit(d0), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(d1), 
        .segments(HEX1)
        );

	hex_decoder H2(
	.hex_digit(d2), 
	.segments(HEX2)
	);

	hex_decoder H3(
	.hex_digit(d3), 
	.segments(HEX3)
	);

endmodule

module part2(
	input clk,
	input resetn,
	input next,
	input go,
	input [17:0] switches,

	output [13:0] temp,
	output temp2,

	output [3:0] d3,
	output [3:0] d2,
	output [3:0] d1,
	output [3:0] d0
    );

    // lots of wires to connect our datapath and control
    wire ld_dig3;
    wire ld_dig2;
    wire ld_dig1;
    wire ld_dig0;
	wire do_mult;
	wire chk_seq;

    control C0(
	.clk(clk),
	.resetn(resetn),
	.next(next),
	.go(go),
	.ld_dig3(ld_dig3),
	.ld_dig2(ld_dig2),
	.ld_dig1(ld_dig1),
	.ld_dig0(ld_dig0),
	.do_mult(do_mult),
	.chk_seq(chk_seq)
    );

    datapath D0(
	.clk(clk),
	.resetn(resetn),
	.switches(switches),
	.ld_dig3(ld_dig3),
	.ld_dig2(ld_dig2),
	.ld_dig1(ld_dig1),
	.ld_dig0(ld_dig0),
	.do_mult(do_mult),
	.chk_seq(chk_seq),
	.temp(temp),
	.temp2(temp2),
	.d3(d3),
	.d2(d2),
	.d1(d1),
	.d0(d0)
    );
                
 endmodule

module control(
    input clk,
    input resetn,
	input next,
	input go,

    output reg  ld_dig3,
    output reg  ld_dig2,
    output reg  ld_dig1,
    output reg  ld_dig0,
	output reg do_mult,
	output reg chk_seq
    );

    reg [5:0] current_state, next_state; 
    
    localparam  S_WAIT_DEC        = 5'd0,
                S_LOAD_DIGIT3   = 5'd1,
                S_LOAD_DIGIT2   = 5'd2,
                S_LOAD_DIGIT1   = 5'd3,
                S_LOAD_DIGIT0   = 5'd4,
		S_LOAD_DIGIT_WAIT   = 5'd5,
		S_WAIT_BIN_WAIT        = 5'd6,
		S_WAIT_BIN        = 5'd7;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
		S_WAIT_DEC: next_state = next ? S_LOAD_DIGIT3 : (go ? S_WAIT_BIN_WAIT : S_WAIT_DEC);
                S_LOAD_DIGIT3: next_state = S_LOAD_DIGIT2;
                S_LOAD_DIGIT2: next_state = S_LOAD_DIGIT1;
                S_LOAD_DIGIT1: next_state = S_LOAD_DIGIT0;
                S_LOAD_DIGIT0: next_state = S_LOAD_DIGIT_WAIT;
                S_LOAD_DIGIT_WAIT: next_state = next ? S_LOAD_DIGIT_WAIT : S_WAIT_DEC;
                S_WAIT_BIN_WAIT: next_state = go ? S_WAIT_BIN_WAIT : S_WAIT_BIN;
		S_WAIT_BIN: next_state = S_WAIT_BIN;
            default:     next_state = S_WAIT_DEC;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_dig3 = 1'b0;
        ld_dig2 = 1'b0;
        ld_dig1 = 1'b0;
        ld_dig0 = 1'b0;
	do_mult = 1'b0;
	chk_seq = 1'b0;

        case (current_state)
            S_LOAD_DIGIT3: begin
                ld_dig3 = 1'b1;
                end
            S_LOAD_DIGIT2: begin
                ld_dig2 = 1'b1;
                end
            S_LOAD_DIGIT1: begin
                ld_dig1 = 1'b1;
                end
            S_LOAD_DIGIT0: begin
                ld_dig0 = 1'b1;
                end
            S_WAIT_BIN_WAIT: begin
                do_mult = 1'b1;
                end
            S_WAIT_BIN: begin
                chk_seq = 1'b1;
                end
        endcase
    end
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_WAIT_DEC;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input [17:0] switches,
    input ld_dig3,
    input ld_dig2,
    input ld_dig1,
    input ld_dig0,
	input do_mult,
	input chk_seq,

	output [13:0] temp,
	output temp2,

	output reg [3:0] d3,
	output reg [3:0] d2,
	output reg [3:0] d1,
	output reg [3:0] d0

    );

    reg [13:0] answer;
	assign temp = answer;
    
    always@(posedge clk) begin
        if(!resetn) begin
            d3 <= 4'b0; 
            d2 <= 4'b0; 
            d1 <= 4'b0; 
            d0 <= 4'b0; 
        end
        else begin
		if (do_mult)
			answer = (d3 * 10'b11111_01000) + (d2 * 10'b00011_00100) + (d1 * 10'b00000_01010) + (d0 * 10'b00000_00001);
		if (bin != 4'b1111)
		begin
		    if(ld_dig3)
		        d3 <= d2;
		    if(ld_dig2)
		        d2 <= d1;
		    if(ld_dig1)
		        d1 <= d0;
		    if(ld_dig0)
			d0 <= bin;
		end
		if (chk_seq)
		begin
			
		end
        end
    end

	wire [13:0] check;
	assign check = ~(answer ^ switches[13:0]);
	assign temp2 = ((check == 14'b11111_11111_1111) && (chk_seq));
	

	wire [3:0] bin;
	sw_bin s(
		.switches(switches[9:0]),
		.bin(bin)
	);
 
/*
    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            data_result <= 8'b0; 
        end
        else 
            if(ld_r)
                data_result <= alu_out;
    end*/

	/*
    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'b0;
        endcase
    end*/
    
endmodule

module sw_bin(
	input [9:0] switches,
	output reg [3:0] bin
);

	always @(*)
    begin
        case (switches)
            10'b00000_00001: bin = 4'b0000;
            10'b00000_00010: bin = 4'b0001;
            10'b00000_00100: bin = 4'b0010;
            10'b00000_01000: bin = 4'b0011;
            10'b00000_10000: bin = 4'b0100;
            10'b00001_00000: bin = 4'b0101;
            10'b00010_00000: bin = 4'b0110;
            10'b00100_00000: bin = 4'b0111;
            10'b01000_00000: bin = 4'b1000;
            10'b10000_00000: bin = 4'b1001;
	    default: bin = 4'b1111;
        endcase
    end
endmodule
