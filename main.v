module Panorama(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, LEDG);
    input [17:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [17:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [7:0] LEDG;

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

	wire [3:0] timer_tens;
	wire [3:0] timer_ones;

    part2 u0(
	.clk(CLOCK_50),
	.resetn(resetn),
	.next(next),
	.go(go),
	.check(~KEY[2]),
	.switches(SW[17:0]),

	.ledr(LEDR),
	.ledg(LEDG),

	.temp(),
	.temp2(),
	.hint(SW[17]),

	.timer_tens(timer_tens),
	.timer_ones(timer_ones),

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

	hex_decoder H4(
	.hex_digit(timer_ones), 
	.segments(HEX4)
	);

	hex_decoder H5(
	.hex_digit(timer_tens), 
	.segments(HEX5)
	);

endmodule

module part2(
	input clk,
	input resetn,
	input next,
	input go,
	input check,
	input [17:0] switches,

	output [17:0] ledr,
	output [7:0] ledg,
	input hint,

	output [13:0] temp,
	output temp2,

	output [4:0] timer_tens,
	output [4:0] timer_ones,

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
	wire chk_seq2;

	wire endtime;
	wire won;
	wire over;
	wire overwait;

    control C0(
	.clk(clk),
	.resetn(resetn),
	.next(next),
	.go(go),
	.check(check),
	.endtime(endtime),
	.won(won),
	.over(over),
	.overwait(overwait),
	.ld_dig3(ld_dig3),
	.ld_dig2(ld_dig2),
	.ld_dig1(ld_dig1),
	.ld_dig0(ld_dig0),
	.do_mult(do_mult),
	.chk_seq(chk_seq),
	.chk_seq2(chk_seq2)
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
	.chk_seq2(chk_seq2),
	.over(over),
	.overwait(overwait),
	.temp(temp),
	.temp2(temp2),
	.ledr(ledr),
	.ledg(ledg),
	.hint(hint),
	.timer_tens(timer_tens),
	.timer_ones(timer_ones),
	.endtime(endtime),
	.won(won),
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
	input check,

	input endtime,
	input won,

    output reg  ld_dig3,
    output reg  ld_dig2,
    output reg  ld_dig1,
    output reg  ld_dig0,
	output reg do_mult,
	output reg chk_seq,
	output reg chk_seq2,

	output reg over,
	output reg overwait
    );

    reg [5:0] current_state, next_state; 
    
    localparam  S_WAIT_DEC        = 5'd0,
                S_LOAD_DIGIT3   = 5'd1,
                S_LOAD_DIGIT2   = 5'd2,
                S_LOAD_DIGIT1   = 5'd3,
                S_LOAD_DIGIT0   = 5'd4,
		S_LOAD_DIGIT_WAIT   = 5'd5,
		S_WAIT_BIN_WAIT        = 5'd6,
		S_WAIT_BIN        = 5'd7,
		S_WAIT_BIN_CHECK = 5'd8,
		S_WAIT_BIN_CHECK_WAIT = 5'd9,
		S_GAMEOVER = 5'd10,
		S_GAMEOVER_WAIT = 5'd11;
    
	wire gameover;
	assign gameover = (endtime || won);
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
		//S_WAIT_BIN: next_state = check ? S_WAIT_BIN_CHECK : S_WAIT_BIN;
		S_WAIT_BIN: next_state = gameover ? S_GAMEOVER : (check ? S_WAIT_BIN_CHECK : S_WAIT_BIN);
		S_WAIT_BIN_CHECK: next_state = gameover ? S_GAMEOVER : S_WAIT_BIN_CHECK_WAIT;
		//S_WAIT_BIN_CHECK_WAIT: next_state = check ? S_WAIT_BIN_CHECK_WAIT : S_WAIT_BIN;
		S_WAIT_BIN_CHECK_WAIT: next_state = gameover ? S_GAMEOVER : (check ? S_WAIT_BIN_CHECK_WAIT : S_WAIT_BIN);

		S_GAMEOVER: next_state = S_GAMEOVER_WAIT;
		S_GAMEOVER_WAIT: next_state = S_GAMEOVER_WAIT;
            default:     next_state = S_WAIT_DEC;
        endcase
    end // state_table

	//reg result;
	//assign ledg = ((result == 1'b1) && (current_state == S_GAMEOVER_WAIT)) ? 8'b11111111 : 8'b00000000;
	//assign ledr = ((result == 1'b0) && (current_state == S_GAMEOVER_WAIT)) ? 18'b11_11111111_11111111 : 18'b00_00000000_00000000;

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
	chk_seq2 = 1'b0;
	over = 1'b0;
	overwait = 1'b0;

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
            S_WAIT_BIN_CHECK: begin
                chk_seq2 = 1'b1;
		chk_seq = 1'b1;
                end
            S_WAIT_BIN_CHECK_WAIT: begin
                chk_seq = 1'b1;
                end

            S_GAMEOVER: begin
                over = 1'b1;
                end
            S_GAMEOVER_WAIT: begin
                overwait = 1'b1;
                end

            /*S_GAMEOVER: begin
                if (won == 1'b1)
			result = 1'b1;
		else if (endtime == 1'b1)
			result = 1'b0;
                end*/
            /*S_GAMtemp2EOVER_WAIT: begin
                if (result == 1'b1)
			assign ledg = 8'b11111111;
		else if (result == 1'b0)
			assign ledr = 17'b1_11111111_11111111;
                end*/
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
endmodule	//assign ledg = ((result == 1'b1) && (current_state == S_GAMEOVER_WAIT)) ? 8'b11111111 : 8'b00000000;
	//assign ledr = ((result == 1'b0) && (current_state == S_GAMEOVER_WAIT)) ? 18'b11_11111111_11111111 : 18'b00_00000000_00000000;

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
	input chk_seq2,

	output [13:0] temp,
	output temp2,

	output [17:0] ledr,
	output [7:0] ledg,
	input hint,

	output [4:0] timer_tens,
	output [4:0] timer_ones,

	output endtime,
	output won,
	input over,
	input overwait,

	output reg [3:0] d3,
	output reg [3:0] d2,
	output reg [3:0] d1,
	output reg [3:0] d0

    );

    reg [13:0] answer;
	assign temp = answer;

	reg result;
    
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
		if (over)
		begin
			result = correct;
		end
        end
    end

	assign ledg = ((result == 1'b1) && (overwait == 1'b1)) ? 8'b11111111 : 8'b00000000;
	//assign ledr = ((result == 1'b0) && (overwait == 1'b1)) ? 18'b11_11111111_11111111 : 18'b00_00000000_00000000;
	assign ledr[0] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[0]); //check if chk_seq is 1
	assign ledr[1] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[1]);
	assign ledr[2] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[2]);
	assign ledr[3] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[3]);
	assign ledr[4] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[4]);
	assign ledr[5] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[5]);
	assign ledr[6] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[6]);
	assign ledr[7] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[7]);
	assign ledr[8] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[8]);
	assign ledr[9] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[9]);
	assign ledr[10] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[10]);
	assign ledr[11] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[11]);
	assign ledr[12] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[12]);
	assign ledr[13] = ((result == 1'b0) && (overwait == 1'b1)) || (hint && ~check[13]);
	assign ledr[14] = (result == 1'b0) && (overwait == 1'b1);
	assign ledr[15] = (result == 1'b0) && (overwait == 1'b1);
	assign ledr[16] = (result == 1'b0) && (overwait == 1'b1);
	assign ledr[17] = (result == 1'b0) && (overwait == 1'b1);

	wire [13:0] check;
	wire correct;
	assign correct = check == 14'b11111_11111_1111;
	assign check = ~(answer ^ switches[13:0]);
	assign temp2 = (correct && chk_seq);
	assign won = (correct && chk_seq2);
	

	wire [3:0] bin;
	sw_bin s(
		.switches(switches[9:0]),
		.bin(bin)
	);

	/*wire p1_wire;
	pulse_50000000 p1(
		.clock(clk),
		.reset(~chk_seq),
		.enable(chk_seq),
		.pulse(p1_wire),
		.q()
	);

	wire p2_wire;
	wire [4:0] timeleft;
	pulse_30(
		.clock(p1_wire),
		.reset(~chk_seq),
		.enable(chk_seq),
		.pulse(),
		.q(timeleft)
	);*/

	wire p1_wire;
	assign endtime = p1_wire;
	wire [30:0] q1;
	pulse_1500mill p1(
		.clock(clk),
		.reset(~chk_seq && ~chk_seq2),
		.enable(chk_seq || chk_seq2),
		.pulse(p1_wire),
		.sub(chk_seq2 && ~correct),
		.q(q1)
	);

	wire [4:0] timeleft = q1 / 26'b10_11111010_11110000_10000000;
	assign timer_tens = timeleft / 4'b1010;
	assign timer_ones = timeleft % 4'b1010;
    
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
