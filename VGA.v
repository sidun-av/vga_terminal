`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:44:00 12/28/2019 
// Design Name: 
// Module Name:    VGA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module VGA(clk, reset, COLORS, HSYNC, VSYNC, VGA_out);
		input wire clk, reset;
		input wire [7:0] COLORS;
		output reg HSYNC, VSYNC;
		output reg [7:0] VGA_out;
		
		reg clk_cnt=1'd0; //initial
		reg pixel_clk =1'd0;	// initial
		reg [9:0] pixel_cnt;
		reg [9:0] line_cnt;
		
		localparam HS_Tpw = 10'd96;
		localparam HS_Ts = 10'd799;
		
		localparam VS_Tpw =10'd2;
		localparam VS_Ts = 10'd524;
		
		localparam HS_Tbp = 10'd48;
		localparam HS_Tfp = 10'd16;
		
		//clock divider 100MHz/4 = 25 MHz
		always @ (posedge clk)
					begin
					clk_cnt<=clk_cnt+1'd1;
					
					if (clk_cnt)
							begin
									pixel_clk<=~pixel_clk;
									clk_cnt<=1'd0;
						end
					end
		//HS and VS generation
		always @ (posedge pixel_clk)
					if (reset)
							begin
									pixel_cnt<=10'd0;
									line_cnt<=10'd0;
									HSYNC<=1'd0;
									VSYNC<=1'd0;
							end
					else
							begin
									//pixel and line counters, HS triggers
									pixel_cnt<=pixel_cnt+10'd1;
									if (pixel_cnt==HS_Ts)//reached the end of line
										begin
												pixel_cnt<=10'd0;
												HSYNC<=1'd0;//start of line sync pulse
												line_cnt<=line_cnt+10'd1;//increment line counter
												//VS triggers
														if (line_cnt == VS_Ts)//reached the end of frame
																begin
																		line_cnt<=10'd0;
																		VSYNC<=1'd0;//start of frame sync pulse
																end
														else if (line_cnt>=VS_Tpw)//end of the frame sync pulse
														VSYNC<=1'd1;
										end
									
									else if (pixel_cnt>=HS_Tpw)//the end of the sync pulse
										HSYNC<=1'd1;
										
					//VGA data sync
					if((pixel_cnt>=(HS_Tpw+HS_Tbp))&&(pixel_cnt<=(HS_Ts-HS_Tfp)))
							VGA_out<=COLORS;
							else
							VGA_out<=8'd0;
							end
endmodule
