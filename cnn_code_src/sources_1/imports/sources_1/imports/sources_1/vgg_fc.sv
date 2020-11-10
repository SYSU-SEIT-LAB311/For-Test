
// chinese GBK 936 
//////////////////////////////////////////////////////
/*
FC ��ģ��
1. �����ͽӿ�
2.RAM ƹ�ҽӿ��߼���� 






*/
/////////////////////////////////////////////////////

/* fifo 
��ƿ�� AF*data_width
��� 2*FIN1
1 clk read delay
program empty ��FIN_max; 
���data count
*/
/* ram
batch? sigle dual port
��� AF*data_width 
��� FIN1
1 clk read delay
����byte write enable 

*/

module vgg_fc
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
	parameter ADDR_WIDTH=32 
	
)
(	
	input wire clk,
	input wire rstn,
	
	// interface with FC_BUFFER_WRITER
	input wire FC_data_valid,
	output reg FC_PE_ready,
	output reg FC_buffer_switch, // ά��?��clk����
	
	// Ram1 read 
	output reg  [ADDR_WIDTH-1:0] RAM1_rd_ADDR,
	output reg  RAM1_rden,              // ͳһ����Batch��ram
	input wire  [AF-1:0][DATA_WIDTH-1:0] RAM1_rd_data[BATCH],
	
	//ram1 write 
  output reg  [ADDR_WIDTH-1:0] RAM1_wr_ADDR,
	output reg  RAM1_wren,              // ͳһ����Batch��ram
	output reg  [AF-1:0]RAM1_byte_en,   // д��ʱ��1������һ������д�룬����һ��addrҪͨ����byte_enѡд��AF��
	output reg  [AF-1:0][DATA_WIDTH-1:0] RAM1_wr_data[BATCH], 
	
	//ram2 read  
	output reg  [ADDR_WIDTH-1:0] RAM2_rd_ADDR,
	output reg  RAM2_rden,              // ͳһ����Batch��ram
  input  wire [AF-1:0][DATA_WIDTH-1:0] RAM2_rd_data[BATCH], 
   
  //ram2 write 
  output reg  [ADDR_WIDTH-1:0] RAM2_wr_ADDR,
	output reg  RAM2_wren,              // ͳһ����Batch��ram 
	output reg  [AF-1:0]RAM2_byte_en,  // д��ʱ��1������һ������д�룬����һ��addrҪͨ����byte_enѡд��AF��
	output reg  [AF-1:0][DATA_WIDTH-1:0] RAM2_wr_data[BATCH],  
	
	// weight fifo read 
	output reg weight_fifo_rden,            
	input wire [AF-1:0][DATA_WIDTH-1:0] fifo_weight, //1�����ݸ��ø�batch������data
	output wire [ADDR_WIDTH-1:0] prog_empty_thresh,
	input wire prog_empty,                         //����programeble empty����valid����weight counter Ϊfin_maxʱ��ȡ��empty(������һ�μ���)

  // result output 
  output reg [AF-1:0][DATA_WIDTH-1:0] result_data[BATCH], 
  input wire [ADDR_WIDTH-1:0] result_rd_ADDR, // 0- $ceil(real(FOUT3)/AF)-1
  output reg result_valid,
  input wire result_ready
);

	 
//*******************************************************************************************//
//************************************1.�����ͽӿ�****************************************//
// ram in  , read data from ram to pe
reg  [ADDR_WIDTH-1:0] RAM_in_addr;    // Fin_counter ������
reg  RAM_in_rden;
reg [AF-1:0][DATA_WIDTH-1:0]RAM_in_data[BATCH];


// ram out , write data from pe to ram
reg  [ADDR_WIDTH-1:0] RAM_out_addr;   // Fout_counter ������
reg  RAM_out_wren;
reg  [AF-1:0]RAM_out_byte_en;          // byte write enable
wire [DATA_WIDTH-1:0]RAM_out_data[BATCH]; //  PE output ����

// state mechine reg 
reg [log2(FOUT1):0] Fout_counter;
reg [log2(AF):0] Fout_counter_AF;
reg [log2(FOUT1/AF):0] Fout_counter_AF_addr;
reg [log2(FIN1):0] Fin_counter;
reg [log2(FIN1):0] Fin_MAX;
reg [log2(FOUT1)-1:0] Fout_MAX;
reg [2:0] FC_Layer;
reg pe_run;

// batch pe register
reg  [AF-1:0][DATA_WIDTH-1:0]pe_in_data[BATCH];
reg  [AF-1:0][WEIGHT_WIDTH-1:0]pe_in_weight;

// fifo_valid_logic 
wire weight_valid;
assign weight_valid=!prog_empty;     
assign prog_empty_thresh=Fin_MAX-2; // ��fifo ����1�ּ������ݣ�1*fin����ȡ��prog empty��ʹ��valid��Ч

//**********************************1.�����ͽӿ�******����*********************************//
//*******************************************************************************************//


//*******************************************************************************************//
//*****************************2.RAM ƹ�ҽӿ��߼����************************************//
integer i,j,k;
// ʹ���ڿ����߼����� data in  ��data out ��͸���ģ�����Ҫ��ע pingpong�л�
always@(*)  // ram  pingpong bonding , combinational logic circuit
begin 
// Ԥ�ȳ�ʼ�����reg��ʵ�ʵ�·��Ϊwire������ֹ©���ã�����latch
//ram1 read	
	RAM1_rd_ADDR        =8399;
	RAM1_rden           =0;
	//RAM_in_data         =0;
	foreach(RAM_in_data[i])
		RAM_in_data[i]={AF*DATA_WIDTH{1'b0}};

//ram1 write	                    
	RAM1_wr_ADDR        =0;
	RAM1_wren           =0;
	RAM1_byte_en        =0;
	//RAM1_wr_data        =0;
	foreach(RAM1_wr_data[i])
			RAM1_wr_data[i]={AF*DATA_WIDTH{1'b0}};
//ram2 read 	                    
	RAM2_rd_ADDR        =FIN2+50;
	RAM2_rden           =0;

//ram2 write	                    
	RAM2_wr_ADDR        =0;
	RAM2_wren           =0;
	RAM2_byte_en        =0;
	//RAM2_wr_data        =0;
	foreach(RAM2_wr_data[i])
			RAM2_wr_data[i]={AF*DATA_WIDTH{1'b0}};
			
//result 
 	//result_data         =0;
 	foreach(result_data[i])
			result_data[i]={AF*DATA_WIDTH{1'b0}};
			
//  addr
	RAM_in_addr={'0,Fin_counter};
	RAM_out_addr={'0,Fout_counter_AF_addr};	
	RAM_out_byte_en=(RAM_out_wren_t==1)? 1'b1<<(Fout_counter_AF) : {AF{1'b0}};	
// RAM_in_rden  and RAM_out_wren is control in state mechine
// RAM_out_data is connected with  pe  output
		
			
		case(FC_Layer)
			2'd1: 
				begin   
				 // datain - ram1-read 
					RAM1_rd_ADDR=RAM_in_addr;
					RAM1_rden=RAM_in_rden;	   // ͬʱ��AJ������
					RAM_in_data=RAM1_rd_data;
					
				 //dataout - ram2-write
				  RAM2_wr_ADDR=RAM_out_addr;  
				  RAM2_wren=RAM_out_wren;    // ����д��ͬһ����ַ��дAJ�Σ�ÿ��batch��ram				  
				  RAM2_byte_en=RAM_out_byte_en;
				  for(i=0;i<BATCH;i=i+1)
				  	begin 
				  		RAM2_wr_data[i]= {AF{RAM_out_data[i]}};  // ���� AF�Σ� ͨ��byte_en ѡͨ
				  	end 
				end
			2'd2:
				begin 
					// datain  - ram2-read 
					RAM2_rd_ADDR=RAM_in_addr;
					RAM2_rden=RAM_in_rden;
					RAM_in_data=RAM2_rd_data;
					// dataout - ram1-write
					RAM1_wr_ADDR=RAM_out_addr;
				  RAM1_wren=RAM_out_wren;				  			
				  RAM1_byte_en=RAM_out_byte_en;
				  for(i=0;i<BATCH;i=i+1)
				  	begin 
				  		RAM1_wr_data[i]= {AF{RAM_out_data[i]}};  // ���� AF�Σ� ͨ��byte_en ѡͨ
				  	end 
				end 
			2'd3:
				begin 
					// datain - ram1-read 
					RAM1_rd_ADDR=RAM_in_addr;
					RAM1_rden=RAM_in_rden;	
					RAM_in_data=RAM1_rd_data;
					
				  //dataout - ram2-write
				  RAM2_wr_ADDR=RAM_out_addr;  
				  RAM2_wren=RAM_out_wren;    // ����д��ͬһ����ַ��дAJ�Σ�ÿ��1��addr
				  RAM2_byte_en=RAM_out_byte_en;
				  for(i=0;i<BATCH;i=i+1)
				  	begin 
				  		RAM2_wr_data[i]= {AF{RAM_out_data[i]}};  // ���� AF�Σ� ͨ��byte_en ѡͨ Ҫд���
				  	end 
				  
				 //result_output -  ram2-read
				  RAM2_rd_ADDR=result_rd_ADDR;
					RAM2_rden=result_ready&result_valid;
					result_data=RAM2_rd_data;
				end
					
			default:
			begin   
				 // datain - ram1-read 
					RAM1_rd_ADDR=RAM_in_addr;
					RAM1_rden=RAM_in_rden;	   // ͬʱ��AJ������
					RAM_in_data=RAM1_rd_data;
					
				 //dataout - ram2-write
				  RAM2_wr_ADDR=RAM_out_addr;  
				  RAM2_wren=RAM_out_wren;    // ����д��ͬһ����ַ��дAJ�Σ�ÿ��batch��ram				  
				  RAM2_byte_en=RAM_out_byte_en;
				  for(i=0;i<BATCH;i=i+1)
				  	begin 
				  		RAM2_wr_data[i]= {AF{RAM_out_data[i]}};  // ���� AF�Σ� ͨ��byte_en ѡͨ
				  	end 
				  //result_output -  ram2-read
				  RAM2_rd_ADDR=result_rd_ADDR;
					RAM2_rden=result_ready&result_valid;
					result_data=RAM2_rd_data;
				end
	 endcase
end 
// Ϊ�˸���ʱ����ǰ������ģ�ͳ��������ƹ�ҽӿ�Ѱַʹ��
	 always@(posedge clk or negedge rstn)
 begin 
 	if(rstn==0)
 		begin 
 			Fout_counter_AF<=0;
 			Fout_counter_AF_addr<=0;
 		end 
 		
 	else
 		begin 
 				Fout_counter_AF<=Fout_counter%AF;
 				Fout_counter_AF_addr<=Fout_counter/AF;
 	  end 
 end 




//*****************************2.RAM ƹ�ҽӿ��߼����******����******************************//
//*******************************************************************************************//

//*****************************3.����״̬��**************************************************//
//*******************************************************************************************// 
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
	
	always@(*) //״̬ת��
  begin 
  	if(rstn==0)
  		next_state=STATE1;
  	else 
  		case(current_state)
  			STATE1: //idle
  				next_state=STATE2;
  			STATE2: //wait
  				if(weight_valid==1 && FC_data_valid==1)
  					next_state=STATE3;
  				else 
  					next_state=STATE2;
  			STATE3:	// wait ram 1 clk 			
  					next_state=STATE4; 				
  			STATE4: // ���� batch?  Fin .* weight ,ÿclk��AJ���˷�����һ����hout
  				if(RAM_in_addr==Fin_MAX)  // RAM_in_addr = Fin_counter
  					next_state=STATE5;
  				else 
  					next_state=STATE4;
  			STATE5: // ��ram out д��batch�����hout  
  					next_state=STATE6;
  			STATE6: // �ж�1���Ƿ�����
  				if(Fout_counter<Fout_MAX-1)  // ram_out_addr=Fout_counter/AJ   ram_out_wren= Fout_counter % Aj 
  					next_state=STATE2;
  				else 
  					next_state=STATE7;
  		  STATE7: // �л���һ��
  		  	if(FC_Layer==3)
  		  		next_state=STATE8;
  		  	else 
  		  		next_state=STATE2;
  		  STATE8: // ������
  		  	if(result_ready==1)
  		  		next_state=STATE9;
  		  	else 
  		  		next_state=8;
  		  STATE9: // ������
  		  	if(result_ready==0)
  		  		next_state=STATE2;
  		  	else 
  		  		next_state=STATE9;
  		  
  			
  			default:
  				  next_state=STATE1;
  		endcase
  end 


  // ״̬���������
  always@(posedge clk or negedge rstn )
  begin 
  	if(rstn==0)
  	begin 
  	
  					Fin_MAX<=FIN1;
  					Fout_MAX<=FOUT1;
  					FC_Layer<=1;    // vgg_16  1,2,3 FC
  					pe_run<=0;
            
            Fin_counter<=0; // 0-Fin_MAX-1
            Fout_counter<=0;// 0-Fout_MAX-1
            
            FC_PE_ready<=0;
            FC_buffer_switch<=0;
            result_valid<=0;
            weight_fifo_rden<=0;
            RAM_in_rden<=0;
            RAM_out_wren<=0;           
  	
  	end 
  	else 
  		case (current_state)
  			STATE1:  //idle
  				begin 
  					Fin_MAX<=FIN1;
  					Fout_MAX<=FOUT1;
  					FC_Layer<=1;    // vgg_16  1,2,3 FC
  					pe_run<=0;
            
            Fin_counter<=0; // 0-Fin_MAX-1
            Fout_counter<=0;// 0-Fout_MAX-1
          //  Fout_counter_AF<=0;
            
            FC_PE_ready<=0;
            FC_buffer_switch<=0;
            result_valid<=0;
            weight_fifo_rden<=0;
            RAM_in_rden<=0;
            RAM_out_wren<=0;
                       
  				end 
  			STATE2:  //wait
  				begin 
  					FC_PE_ready<=1;
  					if(weight_valid==1&&FC_data_valid==1)
  						begin // ����Ram��ȡ
  							Fin_counter<=0;
  							weight_fifo_rden<=1;
  							RAM_in_rden<=1;
  						end 
  				end 
  			STATE3: // wait ram 1 clk 
  				begin 
  					Fin_counter<=Fin_counter+1;
  				end 
  			STATE4: // ���� batch?  Fin .* weight ,ÿclk��AJ���˷�����һ����hout
  				begin  
  							pe_in_data<=RAM_in_data; // AJ*data
  							Fin_counter<=Fin_counter+1;
  							
  							pe_in_weight<=fifo_weight;
  							
  							pe_run<=1;
  							weight_fifo_rden<=1;
  							RAM_in_rden<=1;
  							
  							if(Fin_counter==Fin_MAX-1) // RAM_in_addr = Fin_counter 
  							begin 
  								weight_fifo_rden<=0;
  							  RAM_in_rden<=0;
  							end 
  							
  							if(Fin_counter==Fin_MAX)   // RAM ��ȡ�ӳ�1�����ڣ�����Ҫ��ȡ��1������
  							begin 
  								Fin_counter<=0;
  								FC_PE_ready<=0;
  								weight_fifo_rden<=0;
  							  RAM_in_rden<=0;
  							end 
  							
  				end
  			STATE5: // ��ram out д��batcn�����hout 
  				begin 
  					pe_run<=0;
  					RAM_out_wren<=1;
  			  end 
  			STATE6:// �ж�1���Ƿ�����
  				begin 
  					RAM_out_wren<=0;
  					Fout_counter<=Fout_counter+1;
  				//	Fout_counter_AF<=(Fout_counter+1)/AF;
  				end 
  			STATE7: // �л���һ��
  				begin 
  					Fin_counter<=0;
  					Fout_counter<=0;
  				//	Fout_counter_AF<=0;
  					case(FC_Layer)
  						2'd1: 
  							begin 
  								Fout_MAX<=FOUT2;
  								Fin_MAX<=FIN2; 
  								
  								FC_Layer<=2;
  							end 
  						2'd2:
  							begin 
  								Fout_MAX<=FOUT3;
  								Fin_MAX<=FIN3;
  								FC_Layer<=3;
  							end 
  						2'd3: //FC layerȫ���������
  							begin 
  								Fout_MAX<=FOUT1;
  								Fin_MAX<=FIN1;
  								
  							end 
  				  endcase
  				
  					if(FC_Layer==3)
  						FC_buffer_switch<=1; //  FC buffer �л�
  				end 
  			STATE8: // ������
  				begin 
  					FC_buffer_switch<=0;
  					result_valid<=1;
  				end 
  			STATE9: // ������
  				begin 
  					if(result_ready==0)
  					begin 
  						result_valid<=0;
  						FC_Layer<=1;
  					end 
  				end 
  				
  			default:
  			begin 
  					Fin_MAX<=FIN1;
  					Fout_MAX<=FOUT1;
  					FC_Layer<=1;    // vgg_16  1,2,3 FC
  					pe_run<=0;
            
            Fin_counter<=0; // 0-Fin_MAX-1
            Fout_counter<=0;// 0-Fout_MAX-1
            
            FC_PE_ready<=0;
            FC_buffer_switch<=0;
            result_valid<=0;
            result_valid<=0;
            weight_fifo_rden<=0;
            RAM_in_rden<=0; 
            RAM_out_wren<=0;          
  				end 
  		endcase
  end 
  							
//*****************************3.����״̬��***********����***********************************//  							
//*******************************************************************************************//   							
  							
  							
  							
 /***************************/
 //pe array  
/*******************/
// timming optimized  for  one more clk (pe) 
reg pe_run_t;
reg RAM_out_wren_t;

// ��pe�Ŀ��ƺͽ���洢���ӳ�һ�����ڣ���Ϊpe��Ԫ��Ҫ2���ڲ��ܳ��������ˮ��
 always@(posedge clk or negedge rstn)
 begin 
 	if(rstn==0)
 		begin 
 			pe_run_t<=0;
 			RAM_out_wren_t<=0;
 		end 
 		
 	else
 		begin 
 				pe_run_t<=pe_run;
 			  RAM_out_wren_t<= RAM_out_wren; 
 	  end 
 end 
 
 
//**************************ʵ����PE**************************// 
//����Щ�м����ߣ����ܲ�����Ҫ 
reg signed [DATA_WIDTH-1:0]wire_pe_in_data[BATCH][AF];
reg signed [WEIGHT_WIDTH-1:0]wire_pe_in_weight[AF];

always@(*)
begin 	
	foreach(wire_pe_in_data[i,j])
		wire_pe_in_data[i][j]=pe_in_data[i][j];
	foreach(wire_pe_in_weight[i])
		wire_pe_in_weight[i]=pe_in_weight[i];
end 	
 
 
 genvar n;
 generate
 		for(n=0;n<BATCH;n=n+1)
 			begin : pe_batch_loop
 				
			 vgg_fc_pe #(
			    .DATA_WIDTH        ( DATA_WIDTH        ),
			    .PRECISION         (PRECISION          ),
			    .AF                ( AF                ))
			 u_vgg_fc_pe (
			    .rstn                  ( rstn),
			    .clk                   ( clk ),
			    .pe_run                ( pe_run_t ),
			    .weight                ( wire_pe_in_weight ),
			    .data                  ( wire_pe_in_data[n]  ),
			    .partial_sum_quantification  (RAM_out_data[n])         
			);					
  							
      end 
 endgenerate

			
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