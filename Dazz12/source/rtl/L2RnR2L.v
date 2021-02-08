//--------------------------------------------------------------------------------
// Create Date: 12/05/2013
// Module Name: L2RnR2L - rtl
//  
// Description: create 2 random colors at the ends of the lite string
// 
// Revision 0.02 - 
// Revision 1.0 added number of lites inputs
// Revision 1.1 brighten mixed colors
// Revision 1.2 made brightness configurable
// 
//--------------------------------------------------------------------------------

module L2RnR2L(clk8,reset8,frame_busy,cmd_inst,cmd_data,neo_size,sizeplus1,
   l2r_data,l2r_done,l2r_go);

   input clk8;
   input reset8;
   input frame_busy;
   input [3:0] cmd_inst;
   input [27:0] cmd_data;
   input [7:0] neo_size;
   input [7:0] sizeplus1;
   
   output l2r_done;
   output [25:0] l2r_data;
   output l2r_go;
   
   
   reg l2r_done;
   reg [25:0] l2r_data;
   reg l2r_go;
   
   reg [25:0] data_buf;
   
   reg [3:0] rite_blu;
   reg [3:0] rite_grn;
   reg [3:0] rite_red;
   reg [3:0] left_blu;
   reg [3:0] left_grn;
   reg [3:0] left_red;
   
   reg [4:0] mix_blu_int;
   reg [4:0] mix_grn_int;
   reg [4:0] mix_red_int;
   
   reg [3:0] nx_rite_blu;
   reg [3:0] nx_rite_grn;
   reg [3:0] nx_rite_red;
   reg [3:0] nx_left_blu;
   reg [3:0] nx_left_grn;
   reg [3:0] nx_left_red;
   
   reg [3:0] mix_blu;
   reg [3:0] mix_grn;
   reg [3:0] mix_red;
   
   // color mixing mux
   wire [3:0] nx_mix_blu;
   wire [3:0] nx_mix_grn;
   wire [3:0] nx_mix_red;
   
   reg [2:0] num_lites;
   reg [4:0] address;
   reg [11:0] random;
   
   reg [3:0] mainsm;
   reg calc_start;
   reg calc_addr;
   reg calc_lim;
   reg do_compare;
   reg sel_color;
   
   reg [3:0] iteraysm;
   reg [4:0] num_lite_less1;
   reg [4:0] inner_rite_lite;
   reg [4:0] inner_rite_lim;
   reg [4:0] iteray;
   reg iteray_up;
   reg iteray_en;
   reg iteray_done;
   
   reg [2:0] colorsm;
   reg calc_randnum;
   reg calc_color;
   reg calc_mix;
   
   
   wire feedback = random[10] ~^ random[9]; // part of random number generator
   
   reg [4:0] left_addr_lo;
   reg [4:0] left_addr_hi;
   reg [4:0] rite_addr_lo;
   reg [4:0] rite_addr_hi;
   
   reg left_cmp_lo;
   reg left_cmp_hi;
   reg rite_cmp_lo;
   reg rite_cmp_hi;
   reg [1:0] cmp;
   wire [1:0] cmp_int;
	
	reg [7:0] brite;	// made configurable 11_20_20
	reg [7:0] briter;	// brighten mixed colors 11/14/20
   
   
   localparam black = 4'h0;
   
   // main state machine localparams
   localparam s_init  = 4'b0000;
   localparam s_start = 4'b0001;
   localparam s_addr  = 4'b0011;
   localparam s_lim   = 4'b0010;
   localparam s_cmp   = 4'b0110;
   localparam s_color = 4'b0111;
   localparam s_go    = 4'b0101;
   localparam s_busy  = 4'b0100;
   localparam s_done  = 4'b1100;
   localparam s_cmd   = 4'b1001;
   
   // iteration state machine localparams
   localparam i_init  = 4'b0000;
   localparam i_start = 4'b0001;
   localparam i_addr  = 4'b0011;
   localparam i_loop  = 4'b0111;
   localparam i_iter  = 4'b1111;
   localparam i_next  = 4'b1011;
   localparam i_pause = 4'b0110;
   
   // next color state machine localparams
   localparam c_init  = 3'b000;
   localparam c_num   = 3'b001;
   localparam c_color = 3'b011;
   localparam c_mix   = 3'b010;
   localparam c_wait  = 3'b110;
   
   // left and right color selects 
   localparam zero  = 2'b00;
   localparam seven = 2'b01;
   localparam eight = 2'b10;
   localparam fs    = 2'b11;
   
   // compare case statement
   localparam cmp_black = 2'b00;
   localparam cmp_rite  = 2'b01;
   localparam cmp_left  = 2'b10;
   localparam cmp_mix   = 2'b11;
   
   
// start main section
   // main state machine
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            l2r_done   <= 1'b0;
            l2r_go     <= 1'b0;
            num_lites  <= 3'b000;
				brite		  <= 8'h08;
            calc_start <= 1'b0;
            calc_addr  <= 1'b0;
            calc_lim   <= 1'b0;
            do_compare <= 1'b0;
            sel_color  <= 1'b0;
            mainsm     <= s_init;
         end
      else
         case (mainsm)
            s_init:
               begin
                  num_lites <= cmd_data[22:20];
						brite 	 <= cmd_data[19:12];
                  if (cmd_inst == 4'h6)
                     mainsm <= s_start;
               end
            s_start:
               begin
                  calc_start <= 1'b1; // not used anymore
                  mainsm     <= s_addr;
               end
            s_addr:
               begin
                  calc_start <= 1'b0;
                  mainsm     <= s_lim;
               end
            s_lim:
               begin
                  calc_lim   <= 1'b1;
                  mainsm     <= s_cmp;
               end
            s_cmp:
               begin
                  calc_lim   <= 1'b0;
                  do_compare <= 1'b1;
                  mainsm     <= s_color;
               end
            s_color:
               begin
                  do_compare <= 1'b0;
                  sel_color  <= 1'b1;
                  mainsm     <= s_go;
               end
            s_go:
               begin
                  sel_color  <= 1'b0;
                  l2r_go     <= 1'b1;
                  if (frame_busy == 1)
                     mainsm <= s_busy;
               end
            s_busy:
               begin
                  l2r_go <= 1'b0;
                  if (frame_busy == 0)
                     mainsm <= s_done;
               end
            s_done:
               begin
                  calc_addr <= 1'b1;
                  l2r_done  <= 1'b1;
                  mainsm    <= s_cmd;
               end
            s_cmd:
               begin
                  calc_addr <= 1'b0;
                  l2r_done  <= 1'b0;
                  num_lites <= cmd_data[22:20];
						brite 	 <= cmd_data[19:12];
                  if (cmd_inst == 4'h6)
                     mainsm <= s_start;
               end
            default:
               begin
                  l2r_go <= 1'b0;
                  mainsm <= s_cmd;
               end
         endcase
   end
   
   // calculate address of the lite to program
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         address <= 5'b00000;
      else
         if (calc_addr)
            begin
               if (address == neo_size[4:0]) // was 5'b11000
                  address <= 5'b00000; // loop address at max size
               else
                  address <= address + 1'b1;
            end
   end
   
   // calculate address limits
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            left_addr_lo <= 5'b00000;
            left_addr_hi <= 5'b00000;
            rite_addr_lo <= 5'b00000;
            rite_addr_hi <= 5'b00000;
         end
      else
         if (calc_lim)
            begin
               left_addr_lo <= iteray;
               left_addr_hi <= num_lites + iteray; // was num_lite_less1
               rite_addr_lo <= inner_rite_lim - iteray; // was inner_rite_lite
               rite_addr_hi <= neo_size[4:0] - iteray; // was 5'b11000 - iteray
            end
   end
   
   // compare address of the present lite to the range to be lit
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            left_cmp_lo <= 1'b0;
            left_cmp_hi <= 1'b0;
            rite_cmp_lo <= 1'b0;
            rite_cmp_hi <= 1'b0;
         end
      else
         if (do_compare)
            begin
               begin
                  if (address >= left_addr_lo)
                     left_cmp_lo <= 1'b1;
                  else
                     left_cmp_lo <= 1'b0;
               end
               begin
                  if (address <= left_addr_hi)
                     left_cmp_hi <= 1'b1;
                  else
                     left_cmp_hi <= 1'b0;
               end
               begin
                  if (address >= rite_addr_lo)
                     rite_cmp_lo <= 1'b1;
                  else
                     rite_cmp_lo <= 1'b0;
               end
               begin
                  if (address <= rite_addr_hi)
                     rite_cmp_hi <= 1'b1;
                  else
                     rite_cmp_hi <= 1'b0;
               end
            end
   end
   
   // alternative color select
   assign cmp_int = {left_cmp_lo & left_cmp_hi, rite_cmp_lo & rite_cmp_hi};
   
   always @ (cmp_int)
   begin
      cmp <= cmp_int;
   end
	
	// calculate briter value to be 1.5 x brite
	always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         briter <= 8'h0C; 
		else
			begin
				if (calc_start)
					briter <= brite + {1'b0, brite[7:1]};
			end
	end
	
// end main section
   
   
// start iteration section
   // iteration state machine
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            num_lite_less1  <= 5'b00000;
            inner_rite_lite <= 5'b00000;
            inner_rite_lim  <= 5'b00000;
            iteray_en       <= 1'b0;
            iteray_done     <= 1'b0;
            iteraysm        <= i_init;
         end
      else
         case (iteraysm)
            i_init:
               begin
               //   num_lite_less1  <= 5'b00000;
               //   inner_rite_lite <= 5'b00000;
               //   inner_rite_lim  <= 5'b00000;
                  iteray_en       <= 1'b0;
                  iteray_done     <= 1'b0;
                  if (sel_color)
                     iteraysm     <= i_start;
               end
            i_start:
               begin
                  num_lite_less1  <= num_lites - 3'b001;
                  // max lites plus 1 - num_lites
                  inner_rite_lite <= sizeplus1[4:0] - num_lites; 
                  // max lites - num_lites
                  inner_rite_lim  <= neo_size[4:0] - num_lites; 
                  iteraysm        <= i_addr;
               end
            i_addr:
               begin
                  if (address[4:3] == 2'b01)
                     iteraysm <= i_loop;
               end
            i_loop:
               begin
                  if (iteray_up == 1'b0 && iteray == 5'b00000)
                     iteraysm <= i_pause; // no more iterations
                  else
                     iteraysm <= i_iter; // increment interation
               end
            i_iter:
               begin
                  iteray_en <= 1'b1;
                  iteraysm  <= i_next;
               end
            i_next:
               begin
                  iteray_en <= 1'b0;
                  if (address[4] == 1'b1)
                     iteraysm <= i_addr; // loop back
               end
            i_pause:
               begin
                  iteray_done <= 1'b1;
                  if (address == neo_size[4:0] && calc_addr == 1'b1)
                     iteraysm <= i_init; // went through all addresses
               end
            default:
               begin
                  iteraysm <= i_init;
               end
         endcase
   end
   
   // iteration logic
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            iteray    <= 5'b00000;
            iteray_up <= 1'b1;
         end
      else
         begin
            begin
               if (iteray_en == 1'b1 && iteray == inner_rite_lite)
                  iteray_up <= 1'b0;
               else if (iteray_done == 1'b1)
                  iteray_up <= 1'b1;
            end
            if (iteray_en)
               begin
                  if (iteray_up == 1'b1 && iteray < inner_rite_lite)
                     iteray <= iteray + 1'b1;
                  else
                     iteray <= iteray - 1'b1;
               end
         end
   end
// end iteration section
   
   
// start color section   
   // next color state machine
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            calc_randnum <= 1'b0;
            calc_color   <= 1'b0;
            calc_mix     <= 1'b0;
            colorsm      <= c_init;
         end
      else
         case (colorsm)
            c_init:
               begin
                  calc_randnum <= 1'b0;
                  calc_color   <= 1'b0;
                  calc_mix     <= 1'b0;
                  if (address[4] == 1'b1)
                     colorsm <= c_num;
               end
            c_num:
               begin
                  calc_randnum <= 1'b1;
                  colorsm      <= c_color;
               end
            c_color:
               begin
                  calc_randnum <= 1'b0;
                  calc_color   <= 1'b1;
                  colorsm      <= c_mix;
               end
            c_mix:
               begin
                  calc_color   <= 1'b0;
                  calc_mix     <= 1'b1;
                  colorsm      <= c_wait;
               end
            c_wait:
               begin
                  calc_mix     <= 1'b0;
                  if (address[4] == 1'b0)
                     colorsm <= c_init;
               end
            default:
               colorsm <= c_init;
         endcase
   end
   
   // random number generator
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         random <= 12'h563; //can't have an all zero state
      else
         begin
            if (calc_randnum)
               random <= {random[10:0], feedback}; //shift left in the XNOR result
         end
   end
   
   // calculate next left and rite colors
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            nx_rite_blu <= 4'h0;
            nx_rite_grn <= 4'h0;
            nx_rite_red <= 4'h0;
            nx_left_blu <= 4'h0;
            nx_left_grn <= 4'h0;
            nx_left_red <= 4'h0;
         end
      else
         begin
            if (calc_color)
               begin
                  case (random[11:10])
                     3'b00:
                        begin
                           nx_rite_blu <= 4'h0;
                           nx_rite_grn <= 4'h0;
                           nx_rite_red <= 4'hF;
                           nx_left_blu <= 4'h0;
                           nx_left_grn <= 4'h8;
                           nx_left_red <= 4'h0;
                        end
                     3'b01:
                        begin
                           nx_rite_blu <= 4'h0;
                           nx_rite_grn <= 4'h0;
                           nx_rite_red <= 4'hF;
                           nx_left_blu <= 4'h8; 
                           nx_left_grn <= 4'h0;
                           nx_left_red <= 4'h0;
                        end
                     3'b10:
                        begin
                           nx_rite_blu <= 4'h8;
                           nx_rite_grn <= 4'h0;
                           nx_rite_red <= 4'hF;
                           nx_left_blu <= 4'h0;
                           nx_left_grn <= 4'h8;
                           nx_left_red <= 4'hF;
                        end
                     3'b11:
                        begin
                           nx_rite_blu <= 4'h0;
                           nx_rite_grn <= 4'hF;
                           nx_rite_red <= 4'h0;
                           nx_left_blu <= 4'h8;
                           nx_left_grn <= 4'h0;
                           nx_left_red <= 4'h0;
                        end
                     
                  endcase
               end
         end
   end
   
   // calculate the mixture of rite and left lites
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            mix_blu_int <= 5'b00000;
            mix_grn_int <= 5'b00000;
            mix_red_int <= 5'b00000;
         end
      else
         if (calc_mix)
            begin
               mix_blu_int <= nx_rite_blu + nx_left_blu;
               mix_grn_int <= nx_rite_grn + nx_left_grn;
               mix_red_int <= nx_rite_red + nx_left_red;
            end
   end
   
   // if the carry of the addition of the rite and left colors is one then
   // assign max value, else don't.
   assign nx_mix_blu = mix_blu_int[4] ? 4'hF : mix_blu_int[3:0];
   assign nx_mix_grn = mix_grn_int[4] ? 4'hF : mix_grn_int[3:0];
   assign nx_mix_red = mix_red_int[4] ? 4'hF : mix_red_int[3:0];
   
   // load next color at max address 
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            rite_blu <= 4'h0;
            rite_grn <= 4'hF;
            rite_red <= 4'h0;
            left_blu <= 4'h0;
            left_grn <= 4'h0;
            left_red <= 4'hF;
            mix_blu  <= 4'h0;
            mix_grn  <= 4'hF;
            mix_red  <= 4'hF;
         end
      else
         begin
            if (iteray_done == 1'b1)
               begin
                  rite_blu <= nx_rite_blu;
                  rite_grn <= nx_rite_grn;
                  rite_red <= nx_rite_red;
                  left_blu <= nx_left_blu;
                  left_grn <= nx_left_grn;
                  left_red <= nx_left_red;
                  mix_blu  <= nx_mix_blu;
                  mix_grn  <= nx_mix_grn;
                  mix_red  <= nx_mix_red;
               end
         end
   end  
// end color section               
   
   
   // select color of lite being addressed based on the limits
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            l2r_data <= 26'h0000000;
         end
      else
         begin
            if (sel_color)
               begin
                  case (cmp)
                     cmp_black:
                        begin
                           l2r_data <= {1'b0, address, brite, black, black, black};
                        end
                     cmp_rite:
                        begin
                           l2r_data <= {1'b0, address, brite, rite_blu, rite_grn, rite_red};
                        end
                     cmp_left:
                        begin
                           l2r_data <= {1'b0, address, brite, left_blu, left_grn, left_red};
                        end
                     cmp_mix:
                        begin
                           l2r_data <= {1'b0, address, briter, mix_blu, mix_grn, mix_red};
                        end
                  endcase
               end
         end
   end
   
endmodule            
               