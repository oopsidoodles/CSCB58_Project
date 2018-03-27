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

	wire [3:0] score_tens;
	wire [3:0] score_ones;

    part2 u0(
	.clk(CLOCK_50),
	.resetn(resetn),
	.next(next),
	.go(go),
	.check(go),
	.switches(SW[17:0]),

	.ledr(LEDR),
	.ledg(LEDG),

	.temp(),
	.temp2(),
	.hint(SW[17]),

	.timer_tens(timer_tens),
	.timer_ones(timer_ones),
	.score_tens(score_tens),
	.score_ones(score_ones),

	

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

	hex_decoder H6(
	.hex_digit(score_ones), 
	.segments(HEX6)
	);

	hex_decoder H7(
	.hex_digit(score_tens), 
	.segments(HEX7)
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

	output [4:0] score_tens,
	output [4:0] score_ones,

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

	wire reset_digits;

	wire f_timer;
	wire f_duration;
	wire f_flash;
	wire f_check;

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

	.f_timer(f_timer),
	.f_duration(f_duration),
	.f_flash(f_flash),
	.f_check(f_check),

	.reset_digits(reset_digits),
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
	.reset_digits(reset_digits),

	.f_timer(f_timer),
	.f_duration(f_duration),
	.f_flash(f_flash),
	.f_check(f_check),

	.temp(temp),
	.temp2(temp2),
	.ledr(ledr),
	.ledg(ledg),
	.hint(hint),

	.timer_tens(timer_tens),
	.timer_ones(timer_ones),
	.score_tens(score_tens),
	.score_ones(score_ones),

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

	input f_timer,
	input f_duration,
	output reg f_flash,
	output reg f_check,

    output reg  ld_dig3,
    output reg  ld_dig2,
    output reg  ld_dig1,
    output reg  ld_dig0,
	output reg do_mult,
	output reg chk_seq,
	output reg chk_seq2,

	output reg over,
	output reg overwait,

	output reg reset_digits
    );

    reg [5:0] current_state, next_state;
    reg [5:0] current_state_flash, next_state_flash; 
    
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
		S_GAMEOVER_WAIT = 5'd11,
		S_GAMEOVER_WAIT_WAIT = 5'd12,
		S_RESTART_WAIT = 5'd13;

    localparam  F_OFF        = 5'd0,
                F_ON   = 5'd1,
                F_CHECK   = 5'd2;
    
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
		S_WAIT_BIN: next_state = gameover ? S_GAMEOVER : (check ? S_WAIT_BIN_CHECK : S_WAIT_BIN);
		S_WAIT_BIN_CHECK: next_state = gameover ? S_GAMEOVER : S_WAIT_BIN_CHECK_WAIT;
		S_WAIT_BIN_CHECK_WAIT: next_state = gameover ? S_GAMEOVER : (check ? S_WAIT_BIN_CHECK_WAIT : S_WAIT_BIN);

		S_GAMEOVER: next_state = S_GAMEOVER_WAIT;
		S_GAMEOVER_WAIT: next_state = go ? S_GAMEOVER_WAIT : S_GAMEOVER_WAIT_WAIT;
		S_GAMEOVER_WAIT_WAIT: next_state = go ? S_RESTART_WAIT : S_GAMEOVER_WAIT;
		S_RESTART_WAIT: next_state = go ? S_RESTART_WAIT : S_WAIT_DEC;
            default:     next_state = S_WAIT_DEC;
        endcase

	case (current_state_flash)
		F_OFF: next_state_flash = f_timer ? F_ON: F_OFF;
                F_ON: next_state_flash = f_duration ? F_CHECK : F_ON;
                F_CHECK: next_state_flash = F_OFF;
        default:     next_state_flash = F_OFF;
	endcase
    end

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
	reset_digits = 1'b0;

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
            S_GAMEOVER_WAIT_WAIT: begin
                overwait = 1'b1;
                end

            S_RESTART_WAIT: begin
                reset_digits = 1'b1;
                end
        endcase

	f_flash = 1'b0;
	f_check = 1'b0;

	case (current_state_flash)
            F_ON: begin
                f_flash = 1'b1;
                end
            F_CHECK: begin
                f_check = 1'b1;
                end
        endcase
    end
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
	begin
            current_state <= S_WAIT_DEC;
		current_state_flash <= F_OFF;
	end
        else
	begin
            current_state <= next_state;
		current_state_flash <= next_state_flash;
	end
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

	output [4:0] score_tens,
	output [4:0] score_ones,

	output f_timer,
	output f_duration,
	input f_flash,
	input f_check,

	output endtime,
	output won,
	input over,
	input overwait,

	input reset_digits,

	output reg [3:0] d3,
	output reg [3:0] d2,
	output reg [3:0] d1,
	output reg [3:0] d0

    );

    reg [13:0] answer;
	assign temp = answer;

	reg result;

	reg [7:0] score;
	initial score = 8'b00000000;
	assign score_tens = score / 4'b1010;
	assign score_ones = score % 4'b1010;
    
    always@(posedge clk) begin
        if(!resetn || reset_digits) begin
            d3 <= 4'b0;
            d2 <= 4'b0; 
            d1 <= 4'b0; 
            d0 <= 4'b0;
        end
	if (f_check)
	begin
		t2000 = 1'b0;
		t1000 = 1'b0;
		t500 = 1'b0;

		if (timer_tens <= 5'b00000)
			t500 = 1'b1;
		else if (timer_tens <= 5'b00001)
			t1000 = 1'b1;
		else if (timer_tens <= 5'b00010)
			t2000 = 1'b1;
	end
	if (!resetn)
		score <= 8'b00000000;
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
			if (correct)
				score <= score + 1;
		end
        end
    end

	//we tried a for loop but it was far too advanced for our skill set
	assign ledg = (result && overwait) ? 8'b11111111 : 8'b00000000;
	//assign ledr = ((result == 1'b0) && (overwait == 1'b1)) ? 18'b11_11111111_11111111 : 18'b00_00000000_00000000;
	assign ledr[0] = (~result && overwait) || (hint && ~check[0] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[1] = (~result && overwait) || (hint && ~check[1] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[2] = (~result && overwait) || (hint && ~check[2] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[3] = (~result && overwait) || (hint && ~check[3] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[4] = (~result && overwait) || (hint && ~check[4] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[5] = (~result && overwait) || (hint && ~check[5] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[6] = (~result && overwait) || (hint && ~check[6] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[7] = (~result && overwait) || (hint && ~check[7] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[8] = (~result && overwait) || (hint && ~check[8] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[9] = (~result && overwait) || (hint && ~check[9] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[10] = (~result && overwait) || (hint && ~check[10] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[11] = (~result && overwait) || (hint && ~check[11] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[12] = (~result && overwait) || (hint && ~check[12] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[13] = (~result && overwait) || (hint && ~check[13] && chk_seq) || (~hint && f_flash && (chk_seq || chk_seq2));
	assign ledr[14] = (~result && overwait) || (f_flash && (chk_seq || chk_seq2));
	assign ledr[15] = (~result && overwait) || (f_flash && (chk_seq || chk_seq2));
	assign ledr[16] = (~result && overwait) || (f_flash && (chk_seq || chk_seq2));
	assign ledr[17] = (~result && overwait) || (f_flash && (chk_seq || chk_seq2));

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

	wire p1_wire;
	assign endtime = p1_wire;
	wire [30:0] q1;
	pulse_1500mill p1(
		.clock(clk),
		.reset(~(chk_seq || chk_seq2)),
		.enable(chk_seq || chk_seq2),
		.pulse(p1_wire),
		.sub(chk_seq2 && ~correct),
		.q(q1)
	);

	wire [4:0] timeleft = q1 / 26'b10_11111010_11110000_10000000;
	assign timer_tens = timeleft / 4'b1010;
	assign timer_ones = timeleft % 4'b1010;

	reg t2000;
	reg t1000;
	reg t500;
	wire f2000;
	wire f1000;
	wire f500;
	assign f_timer = (f2000 || f1000 || f500);

	pulse_100mill p100mill(
		.clock(clk),
		.reset(~((chk_seq || chk_seq2) && t2000)),
		.enable((chk_seq || chk_seq2) && t2000),
		.pulse(f2000),
		.q()
	);

	pulse_50mill p50mill(
		.clock(clk),
		.reset(~((chk_seq || chk_seq2) && t1000)),
		.enable((chk_seq || chk_seq2) && t1000),
		.pulse(f1000),
		.q()
	);

	pulse_25mill p25mill(
		.clock(clk),
		.reset(~((chk_seq || chk_seq2) && t500)),
		.enable((chk_seq || chk_seq2) && t500),
		.pulse(f500),
		.q()
	);

	pulse_10mill p10mill(
		.clock(clk),
		.reset(~((chk_seq || chk_seq2) && f_flash)),
		.enable((chk_seq || chk_seq2) && f_flash),
		.pulse(f_duration),
		.q()
	);
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
