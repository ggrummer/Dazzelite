//--------------------------------------------------------------------------------
// Create Date: 11/16/2015 4:26:46 PM
// Module Name: sftbyn - rtl
// By: Grant Grummer
//  
// Description: shift lites address by an amount.  
//    Depends on delay from neo_color.
// 
// Revision 0.0 
// 
//--------------------------------------------------------------------------------

module sftbyn(clk8,reset8,frame_start,frame_data,sftbynum,sftbymax,neo_addr);

   input  clk8;
   input  reset8;
   input  frame_start;
   input  [25:0] frame_data;
   input  [7:0]  sftbynum;
   input  [7:0]  sftbymax;
   
   output [7:0]  neo_addr;
   
   reg    [7:0]  neo_addr;
   
   
   // add the amount of shift to address 
   always @ (posedge clk8 or posedge reset8)
   begin
      if (reset8)
         begin
            neo_addr <= 8'h00;
         end
      else
         begin
            if (frame_start === 1'b1)
               begin
                  if (frame_data[25:20] >= sftbymax[5:0])
                     begin
                        // subtract max shift from address
                        neo_addr <= {2'b00, frame_data[25:20] - sftbymax[5:0]};
                     end
                  else
                     begin
                        // add shift to address
                        neo_addr <= {2'b00, frame_data[25:20] + sftbynum[5:0]};
                     end
               end
         end
   end
   
   
endmodule  