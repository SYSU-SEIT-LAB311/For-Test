`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
FC_switch
1. fc data buffer �л�
2. ״̬�������л�״̬

*/
//////////////////////////////////////////////////////////////////////////////////

// chinese GBK 936 
module FC_switch
#(                                                                                                                   
  parameter AF=3,                                                                                                    
  parameter BATCH=9, 	      
  parameter FOUT1=4096,                                                                                              
	parameter FOUT2=4096,                                                                                              
	parameter FOUT3=1000,                                                                                          
                              
  parameter FIN1=8379,          // ע�⣬�����FOUT��������AF     
  parameter FIN2=1366,        // ��FOUT1����fin2�лᱻ��ȫ����������ݻ�������
  parameter FIN3=1366,       // ����weightҲҪ�����ƵĴ������AF��������0��ȫ
  parameter FIN4=1002 ,      // ����������������ݶ༸������Ϊweight=0����Ӱ����                                                                                                        
	parameter WEIGHT_WIDTH=8,                                                                                          
	parameter DATA_WIDTH=8,                                                                                            
	parameter PRECISION=4,  // 1+3+4,  4 decimal                                                                       
  parameter ADDR_WIDTH=32      //��Ϊ�ж�̬��addr��ȫ��addr�ӿڲ�0��32λ                                                                       

)(
	input clk ,
	input rstn,
	
	input writer_done,
	output reg writer_en,
	
	output reg FC_data_valid,
	input wire FC_buffer_switch,
	
  // ram 0 read                                                                                                                          
   output reg  [ADDR_WIDTH-1:0] RAM0_rd_ADDR[BATCH],                                                                                                           // ͳһ����Batch��ram                                                                                      
   input wire   [AF-1:0][DATA_WIDTH-1:0] RAM0_rd_data[BATCH],     
                                                                               
  // ram 0 write                                                                                                                                                                                                                                                                        
   output reg  [ADDR_WIDTH-1:0] RAM0_wr_ADDR[BATCH],                                                                                                                                                                                     
   output reg  [AF-1:0]RAM0_byte_en[BATCH],   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                             
   output reg  [AF-1:0][DATA_WIDTH-1:0] RAM0_wr_data[BATCH],
  
  
   // ram 1 read                                                                                                                          
   output reg  [ADDR_WIDTH-1:0] RAM1_rd_ADDR[BATCH],                                                                                                                                                                                
   input wire   [AF-1:0][DATA_WIDTH-1:0] RAM1_rd_data[BATCH],     
                                                                               
   // ram 1 write                                                                                                                                                                                                                                                                        
   output reg  [ADDR_WIDTH-1:0] RAM1_wr_ADDR[BATCH],                                                                                                                                                                                     
   output reg  [AF-1:0]RAM1_byte_en[BATCH],   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                             
   output reg  [AF-1:0][DATA_WIDTH-1:0] RAM1_wr_data[BATCH],
  
  // ram conv write
   input wire  [ADDR_WIDTH-1:0] RAM_writer_wr_ADDR[BATCH],                                                                                                                                                                                     
   input wire  [AF-1:0]RAM_writer_byte_en[BATCH],   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                             
   input wire  [AF-1:0][DATA_WIDTH-1:0] RAM_writer_wr_data[BATCH],
   
  // FC_ram read 
  input wire  [ADDR_WIDTH-1:0] FC_ram_rd_ADDR,                                                                                                                                                                                
  output reg  [AF-1:0][DATA_WIDTH-1:0] FC_ram_rd_data[BATCH],     
  
  // FC_ram write
  input wire   [ADDR_WIDTH-1:0] FC_ram_wr_ADDR,                                                                                                                                                                                     
  input wire  [AF-1:0]FC_ram_byte_en,   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF�� ,һ�ζ�batch                                                            
  input wire  [AF-1:0][DATA_WIDTH-1:0] FC_ram_wr_data[BATCH]	

    );

reg switch_status;
integer batch;
  always@(*)   //ƹ���л�
  begin 
  	if(switch_status==0)
  		// RAM0-writer RAM1- FC
  		begin 
  			foreach(RAM0_rd_ADDR[batch])
  				RAM0_rd_ADDR[batch]=FIN1+50;

  			
  			RAM0_wr_ADDR=RAM_writer_wr_ADDR;
  			RAM0_byte_en=RAM_writer_byte_en;
  			RAM0_wr_data=RAM_writer_wr_data;
  			
  			
  			foreach(RAM1_rd_ADDR[batch])
  				RAM1_rd_ADDR[batch]=FC_ram_rd_ADDR;
  			FC_ram_rd_data=RAM1_rd_data;
  			
  			foreach(RAM1_wr_ADDR[batch])          
  				RAM1_wr_ADDR[batch]=FC_ram_wr_ADDR; 
  			foreach(RAM1_byte_en[batch])          
  				RAM1_byte_en[batch]=FC_ram_byte_en; 
  			//RAM1_wr_ADDR={BATCH{FC_ram_wr_ADDR}};
  			//RAM1_byte_en={BATCH{FC_ram_byte_en}};
  			RAM1_wr_data=FC_ram_wr_data;
  	 end 
   else  // RAM0-FC RAM1-Writer
   		begin 
   			foreach(RAM0_rd_ADDR[batch])
  				RAM0_rd_ADDR[batch]=FC_ram_rd_ADDR;
   			//RAM0_rd_ADDR={BATCH{FC_ram_rd_ADDR}};
        FC_ram_rd_data=RAM0_rd_data;         
  			
  			foreach(RAM0_wr_ADDR[batch])
  				RAM0_wr_ADDR[batch]=FC_ram_wr_ADDR;
  			foreach(RAM0_byte_en[batch])
  				RAM0_byte_en[batch]=FC_ram_byte_en;                                     
  			//RAM0_wr_ADDR={BATCH{FC_ram_wr_ADDR}};
        //RAM0_byte_en={BATCH{FC_ram_byte_en}};
        RAM0_wr_data=FC_ram_wr_data;
        
        foreach(RAM1_rd_ADDR[batch])
  				RAM1_rd_ADDR[batch]=FIN1+50;   
        
        RAM1_wr_ADDR=RAM_writer_wr_ADDR;
        RAM1_byte_en=RAM_writer_byte_en;
        RAM1_wr_data=RAM_writer_wr_data;
       end 
  end 
  
  localparam STATE1=4'd1,
	          STATE2=4'd2,
	          STATE3=4'd3,
	          STATE4=4'd4,
	          STATE5=4'd5,
	          STATE6=4'd6,
	          STATE7=4'd7,
	          STATE8=4'd8,    
            STATE9=4'd9;
            
   reg [3:0] current_state,next_state;
   always@(posedge clk or negedge rstn)
	begin 
		if(rstn==0)
			current_state<=STATE1;
		else 
			current_state<=next_state;          
	end 
	
	always@(*) 
  begin 
  	if(rstn==0)
  		next_state=STATE1;
  	else 
  		case(current_state)
  			STATE1: //idle
  				next_state=STATE2;
  		  STATE2: // RAM0-writer RAM1- FC
  		  	if(writer_done==1)
  		  		next_state=STATE3;
  		  	else 
  		  		next_state=STATE2;
  		  STATE3: // RAM0-FC RAM1-Writer
  		  	if(FC_buffer_switch==1 && writer_done==0)
  		  		next_state=STATE4;
  		  	else if  (FC_buffer_switch==1 && writer_done==1)
  		  	  next_state=STATE5;
  		  	else 
  		  		next_state=STATE3;
  		   
  		  STATE4: // wait RAM1-writer done
  		  	if(writer_done==1)
  		  		next_state=STATE5;
  		  	else 
  		  		next_state=STATE4;
  		  
  		  STATE5: // RAM0-writer RAM1- FC
  		  	if(FC_buffer_switch==1 && writer_done==0)
  		  		next_state=STATE6;
  		  	else if  (FC_buffer_switch==1 && writer_done==1)
  		  	  next_state=STATE3;
  		  	else 
  		  		next_state=STATE5;
  		  STATE6: // wait RAM0-writer done
  		  	if(writer_done==1)
  		  		next_state=STATE3;
  		  	else 
  		  		next_state=STATE6;
      default: next_state=STATE1;
     endcase
  end 
  
   always@(posedge clk or negedge rstn)
		begin 
			if(rstn==0)
				begin 
							switch_status<=0;
							writer_en<=0;
							FC_data_valid<=0;
				end 
			else 
				case(current_state)
					STATE1:
						begin 
							switch_status<=0;
							//writer_en<=0;
							FC_data_valid<=0;
							writer_en<=1;
						end 
					STATE2:// RAM0-writer RAM1- FC ��ʼ��д��
						begin 
              switch_status<=0;
							writer_en<=0;
							FC_data_valid<=0;
							
							
							
							if(writer_done==1)
								begin 
									switch_status<=~switch_status;
									writer_en<=1;
								end 
						end 
					STATE3:// RAM0-FC RAM1-Writer �ڶ���д��
						begin 
								writer_en<=0;
								FC_data_valid<=1;
								if(FC_buffer_switch==1 && writer_done==0)
									  FC_data_valid<=0;
								else if  (FC_buffer_switch==1 && writer_done==1)
								  begin 
									  switch_status<=~switch_status;
									  writer_en<=1;
									  FC_data_valid<=0;
								  end 
						end 
					STATE4:// wait RAM1-writer done ����ѭ��:��һ��д��
						begin 
								FC_data_valid<=0;
								if(writer_done==1) 
									begin 
									  switch_status<=~switch_status;
									  writer_en<=1;
									  FC_data_valid<=0;
								  end 										 
						end 
					STATE5:// RAM0-writer RAM1- FC  ����ѭ�����ڶ���д��
						begin 
								writer_en<=0;
								FC_data_valid<=1;
								if(FC_buffer_switch==1 && writer_done==0)
									  FC_data_valid<=0;
								else if  (FC_buffer_switch==1 && writer_done==1)
								  begin 
									  switch_status<=~switch_status;
									  writer_en<=1;
									  FC_data_valid<=0;
								  end  
						end 
					 STATE6:// wait RAM0-writer done		����ѭ������һ��д��		 
					   begin 
								FC_data_valid<=0;
								if(writer_done==1) 
									begin 
									  switch_status<=~switch_status;
									  writer_en<=1;
									  FC_data_valid<=0;
								  end 	
							end									 
						
						default:
						 begin 
							switch_status<=0;
							writer_en<=0;
							FC_data_valid<=0;
						end 
				endcase
		end 
			
		 function integer log2(input integer x);
        integer i;
        begin
            log2 = 1;
            for (i = 0; 2**i < x; i = i + 1)
            begin
                log2 = i + 1;
            end
        end
    endfunction
 function integer ceil(input integer x,input integer y);
        integer i;
        begin
            i=x/y;
            if(i*y<x)
            	ceil=(i+1)*y;
            else 
            	ceil=i*y;
        end
    endfunction   				  		
                  
  
endmodule   