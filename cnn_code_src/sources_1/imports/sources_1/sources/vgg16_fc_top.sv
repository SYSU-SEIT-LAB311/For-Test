`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
 ȫ���Ӳ�top �����Ա����棩
 1. ���������fc��Ĳ���ʹ��ԭʼ�Ĳ������ݷ�ʽ��
 2. �����ź�
 3. ������ģ�� vgg_fc
 4. ����weight fifo
 5. ���帺��ƹ���л���fc_switch
 6. 


*/
//////////////////////////////////////////////////////////////////////////////////

// chinese GBK 936 
module vgg16_fc_top
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
	parameter ADDR_WIDTH=32,
	
	parameter REAL_HINT=14,       // �� ctrl ����ʱע�� ��С
	parameter REAL_HOUT=7,	  
	
	parameter K=3,
	parameter S=1,
	
	//last conv configuration
	parameter LAST_PK=2,

	parameter LAST_N=512,
	parameter LAST_Wh=6,
	parameter LAST_Ww=17,
	parameter LAST_Ih=17,
	parameter LAST_Iw=1,
	parameter LAST_Bi=1

  
)(
  input logic clkin,
  input logic rstn,
	// ��������ӿڣ���conv13�����ݶԽӽ��롣
  output logic [LAST_Wh-1:0]pe2row_fifo_array1_rden,                      
  output logic pe2row_ready,                                              
  input  logic [LAST_Wh-1:0][LAST_Iw-1:0][DATA_WIDTH-1:0]fifo_array1_dataout, 
  input  logic pe2row_data_valid,
	
	//ȫ���Ӳ��������
  output logic [AF-1:0][DATA_WIDTH-1:0] result_data[BATCH],
  input logic [ADDR_WIDTH-1:0] result_rd_ADDR, // 0- $ceil(real(FOUT3)/AF)-1
  output logic result_valid,
  input logic result_ready,


  //ȫ���Ӳ�Ȩ����������ӿڡ�
  input logic weight_fifo_wren,
  input logic [AF-1:0][DATA_WIDTH-1:0] weight_fifo_din,
  output logic weight_fifo_full


    );                                                                                               

    logic clk; 
//     clk_wiz_0 u_clk1 
//     (
//     .clk_in1(clkin),
//     .reset(!rstn),
//     .clk_out1(clk)
//     );

//********************��ʼ��RAM�ӿ�*********************//

  assign clk=clkin;
  // ram 0 read
    logic  [ADDR_WIDTH-1:0] RAM0_rd_ADDR[BATCH];                                                                                                           // ͳһ����Batch��ram                                                                                      
    logic   [AF-1:0][DATA_WIDTH-1:0] RAM0_rd_data[BATCH];     
                                                                               
  // ram 0 write                                                                                                                                                                                                                                                                        
    logic  [ADDR_WIDTH-1:0] RAM0_wr_ADDR[BATCH];                                                                                                                                                                                     
    logic  [AF-1:0]RAM0_byte_en[BATCH];   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                             
    logic  [AF-1:0][DATA_WIDTH-1:0] RAM0_wr_data[BATCH];
  
  
   // ram 1 read                                                                                                                          
    logic  [ADDR_WIDTH-1:0] RAM1_rd_ADDR[BATCH];                                                                                                                                                                                
   logic   [AF-1:0][DATA_WIDTH-1:0] RAM1_rd_data[BATCH];     
                                                                               
   // ram 1 write                                                                                                                                                                                                                                                                        
    logic  [ADDR_WIDTH-1:0] RAM1_wr_ADDR[BATCH];                                                                                                                                                                                     
    logic  [AF-1:0]RAM1_byte_en[BATCH];   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                             
    logic  [AF-1:0][DATA_WIDTH-1:0] RAM1_wr_data[BATCH];
  
 
	  // FC_ram read 
	  logic  [ADDR_WIDTH-1:0] FC_ram_rd_ADDR;                                                                                                                                                                                
	  logic  [AF-1:0][DATA_WIDTH-1:0] FC_ram_rd_data[BATCH];     
	  
	  // FC_ram write
	  logic   [ADDR_WIDTH-1:0] FC_ram_wr_ADDR;                                                                                                                                                                                     
	  logic  [AF-1:0]FC_ram_byte_en;   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF�� ;һ�ζ�batch                                                            
	  logic  [AF-1:0][DATA_WIDTH-1:0] FC_ram_wr_data[BATCH]	  ;

                                                                                                                                             
	  //ram2 read                                                                                                                               
	  logic [ADDR_WIDTH-1:0] RAM2_rd_ADDR;                                                                                                
	  logic RAM2_rden;              // ͳһ����Batch��ram                                                                                      
	  logic [AF-1:0][DATA_WIDTH-1:0] RAM2_rd_data[BATCH];                                                                                 
                                                                                                                                             
    //ram2 write                                                                                                                             
    logic  [ADDR_WIDTH-1:0] RAM2_wr_ADDR;                                                                                                
    logic  RAM2_wren;              // ͳһ����Batch��ram                                                                                      
    logic  [AF-1:0]RAM2_byte_en;  // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                                              
    logic  [AF-1:0][DATA_WIDTH-1:0] RAM2_wr_data[BATCH];                                                                                 
                                                                                                                                             
    //  weight fifo read                                                                                                                       
    logic    weight_fifo_rden;                                                                                                              
    logic [AF-1:0][DATA_WIDTH-1:0] fifo_weight; //һ�����ݸ��ø�batch������data                                                                    
    logic [ADDR_WIDTH-1:0] prog_empty_thresh;                                                                                           
    logic prog_empty;                         //����programeble empty����valid����weight counter Ϊfin_maxʱ��ȡ��empty(������һ�μ���)                    
    
    logic FC_data_valid;
    logic FC_PE_ready; 
    logic FC_buffer_switch;
    
    
    logic buffer_writer_done; 
    logic buffer_writer_en;  
    logic  [ADDR_WIDTH-1:0] RAM_writer_wr_ADDR[BATCH];                                                               
    logic  [AF-1:0]RAM_writer_byte_en[BATCH];   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                            
    logic  [AF-1:0][DATA_WIDTH-1:0] RAM_writer_wr_data[BATCH];  
  
  //FC��ģ�飬����fc����㣬���м������ݵĶ����д����
  vgg_fc #(
    .AF           ( AF           ),
    .BATCH        ( BATCH        ),
    .FIN1         ( FIN1         ),
    .FIN2         ( FIN2         ),
    .FIN3         ( FIN3         ),
    .FOUT1        ( FOUT1        ),
    .FOUT2        ( FOUT2        ),
    .FOUT3        ( FOUT3        ),
    .WEIGHT_WIDTH ( WEIGHT_WIDTH ),
    .DATA_WIDTH   ( DATA_WIDTH   ),
    .PRECISION    ( PRECISION    ),
    .ADDR_WIDTH ( ADDR_WIDTH )) 
    u_vgg_fc(
    .clk(clk),                                                               //   input logic clk,                                                                                                        
    .rstn(rstn),                                                             //  	input logic rstn,                                                                                                      
                                                                             //  	                                                                                                                      
                                                                             //  	// interface with FC_BUFFER_WRITER                                                                                    
    .FC_data_valid           (FC_data_valid),                                           //  	input logic FC_data_valid,                                                                                             
    .FC_PE_ready             ( FC_PE_ready                           ),      //  	output logic FC_PE_ready,                                                                                               
    .FC_buffer_switch        ( FC_buffer_switch                      ),      //  	output logic FC_buffer_switch, // ά��һ��clk����                                                                             
                                                                             //  	                                                                                                                      
                                                                             //  	// Ram1 read                                                                                                          
    .RAM1_rd_ADDR            ( FC_ram_rd_ADDR                          ),      //  	output logic  [ADDR_WIDTH-1:0] RAM1_rd_ADDR,                                                                            
    .RAM1_rden               (                                     ),      //  	output logic  RAM1_rden,              // ͳһ����Batch��ram                                                                  
    .RAM1_rd_data            ( FC_ram_rd_data                      ),      //  	input logic  [AF-1:0][DATA_WIDTH-1:0] RAM1_rd_data[BATCH],                                                             
                                                                             //  	                                                                                                                      
                                                                             //  	//ram1 write                                                                                                          
    .RAM1_wr_ADDR            ( FC_ram_wr_ADDR                          ),      //   output logic  [ADDR_WIDTH-1:0] RAM1_wr_ADDR,                                                                           
    .RAM1_wren               (                                       ),      //  	output logic  RAM1_wren,              // ͳһ����Batch��ram                                                                  
    .RAM1_byte_en            ( FC_ram_byte_en                         ),      //  	output logic  [AF-1:0]RAM1_byte_en,   // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                         
    .RAM1_wr_data            ( FC_ram_wr_data                          ),      //  	output logic  [AF-1:0][DATA_WIDTH-1:0] RAM1_wr_data[BATCH],                                                             
                                                                             //  	                                                                                                                      
                                                                             //  	//ram2 read                                                                                                           
    .RAM2_rd_ADDR            ( RAM2_rd_ADDR                          ),      //  	output logic  [ADDR_WIDTH-1:0] RAM2_rd_ADDR,                                                                            
    .RAM2_rden               ( RAM2_rden                             ),      //  	output logic  RAM2_rden,              // ͳһ����Batch��ram                                                                  
    .RAM2_rd_data            ( RAM2_rd_data                          ),      //   input  logic [AF-1:0][DATA_WIDTH-1:0] RAM2_rd_data[BATCH],                                                            
                                                                             //                                                                                                                         
                                                                             //    //ram2 write                                                                                                         
    .RAM2_wr_ADDR            ( RAM2_wr_ADDR                          ),      //   output logic  [ADDR_WIDTH-1:0] RAM2_wr_ADDR,                                                                           
    .RAM2_wren               ( RAM2_wren                             ),      //  	output logic  RAM2_wren,              // ͳһ����Batch��ram                                                                  
    .RAM2_byte_en            ( RAM2_byte_en                          ),      //  	output logic  [AF-1:0]RAM2_byte_en,  // д��ʱ��һ������һ������д�룬����һ��addr��Ҫͨ��byteѡͨд��AF��                                          
    .RAM2_wr_data            ( RAM2_wr_data                          ),      //  	output logic  [AF-1:0][DATA_WIDTH-1:0] RAM2_wr_data[BATCH],                                                             
                                                                             //  	                                                                                                                      
                                                                             //  	// weight fifo read                                                                                                   
    .fifo_weight             ( fifo_weight                           ),      //  	output logic weight_fifo_rden,                                                                                          
    .prog_empty              ( prog_empty                            ),      //  	input logic [AF-1:0][DATA_WIDTH-1:0] fifo_weight, //һ�����ݸ��ø�batch������data                                                
    .weight_fifo_rden        ( weight_fifo_rden                      ),      //  	output logic [ADDR_WIDTH-1:0] prog_empty_thresh,                                                                       
    .prog_empty_thresh       ( prog_empty_thresh                     ),      //  	input logic prog_empty,                         //����programeble empty����valid����weight counter Ϊfin_maxʱ��ȡ��empty(������һ�μ���)
                                                                             //                                                                                                              
                                                                             //    // result output                                                                                                     
    .result_rd_ADDR          ( result_rd_ADDR                        ),      //    output logic [AF-1:0][DATA_WIDTH-1:0] result_data[BATCH],                                                              
    .result_ready            ( result_ready                          ),      //    input logic [ADDR_WIDTH-1:0] result_rd_ADDR, // 0- $ceil(real(FOUT3)/AF)-1                                            
    .result_data             ( result_data                           ),      //    output logic result_valid,                                                                                             
    .result_valid            ( result_valid                          )       //    input logic result_ready                                                                                              
    
);
    

                                         
  user_fifo_prog_empty #(
  .FIFO_WIDTH(AF*DATA_WIDTH),
  .FIFO_DEPTH(16384),
  .FIFO_READ_LATANCY(1)
  ) u_weight_fifo
  (
  .clk (clk ),
  .rstn (rstn),
  .din(weight_fifo_din),
  .wr_en(weight_fifo_wren),
  .rd_en(weight_fifo_rden),
  .user_prog_empty_thresh({32'd0,prog_empty_thresh}),    // �������������λΪZ�������������  ��ramͬ��
  
  .dout(fifo_weight),
  .full(weight_fifo_full),
  .empty(weight_fifo_empty),
  //.data_count(data_count),
  .user_prog_empty(prog_empty)
  
  );
  

 // ���� ƹ���л����ݽ��մ洢����������conv������ݣ�ÿ��batch��fm�� 
  FC_switch #(
   .AF           ( AF           ),
    .BATCH        ( BATCH        ),
    .FIN1         ( FIN1         ),
    .FIN2         ( FIN2         ),
    .FIN3         ( FIN3         ),
    .FOUT1        ( FOUT1        ),
    .FOUT2        ( FOUT2        ),
    .FOUT3        ( FOUT3        ),
    .WEIGHT_WIDTH ( WEIGHT_WIDTH ),
    .DATA_WIDTH   ( DATA_WIDTH   ),
    .PRECISION    ( PRECISION    ),
    .ADDR_WIDTH   (ADDR_WIDTH)      
  ) u_fc_swtich
  ( 
   .clk(clk),
   .rstn(rstn),
   
   .writer_done(buffer_writer_done),
   .writer_en(buffer_writer_en),
   
   .FC_data_valid(FC_data_valid),
   .FC_buffer_switch,
    
   .RAM0_rd_ADDR       (RAM0_rd_ADDR        ),
   .RAM0_rd_data       (RAM0_rd_data        ),
                      
   .RAM0_wr_ADDR       (RAM0_wr_ADDR        ),
   .RAM0_byte_en       (RAM0_byte_en        ),
   .RAM0_wr_data       (RAM0_wr_data        ),
                      
   .RAM1_rd_ADDR       (RAM1_rd_ADDR        ),
   .RAM1_rd_data       (RAM1_rd_data        ),
                      
   .RAM1_wr_ADDR       (RAM1_wr_ADDR        ),
   .RAM1_byte_en       (RAM1_byte_en        ),
   .RAM1_wr_data       (RAM1_wr_data        ),
                      
   .RAM_writer_wr_ADDR (RAM_writer_wr_ADDR  ),
   .RAM_writer_byte_en (RAM_writer_byte_en  ),
   .RAM_writer_wr_data (RAM_writer_wr_data  ),   
                       
   .FC_ram_rd_ADDR     (FC_ram_rd_ADDR      ),
   .FC_ram_rd_data     (FC_ram_rd_data      ),
                    
   .FC_ram_wr_ADDR     (FC_ram_wr_ADDR      ),
   .FC_ram_byte_en     (FC_ram_byte_en      ),
   .FC_ram_wr_data     (FC_ram_wr_data      )
  
  );
  //��conv�Խӣ���ȡpe out �����ݣ�д��fc data buffer
  fc_writer #(
    .AF(AF),
    .BATCH(BATCH),
    .DATA_WIDTH       ( DATA_WIDTH       ),
    .REAL_HINT        ( REAL_HINT        ),  
    .REAL_HOUT        ( REAL_HOUT        ),
    .K                ( K                ),
    .S                ( S                ),
    .LAST_N           ( LAST_N        ),  //  ��0Ӱ�쵽���½硣��Ҫ����ȡ��
    .LAST_Wh          ( LAST_Wh          ),
    .LAST_Ww          ( LAST_Ww          ),
    .LAST_Ih          ( LAST_Ih          ),
    .LAST_Iw          ( LAST_Iw          ),
    .LAST_Bi          ( LAST_Bi          ),  
    .ADDR_WIDTH       ( ADDR_WIDTH       )
   ) u_fc_writer
   (.*);
  
  genvar i;
  generate
  	for(i=0;i<BATCH;i=i+1)
  	   begin : batch_Ram0
  	   	 user_ram_byte_en #(
  	   	 .RAM_DEPTH(FIN1+100),
  	   	 .RAM_WIDTH(AF*DATA_WIDTH)
  	   	 ) RAM_0
  	   	 (
  	   	 .clk(clk),
  	   	 .wea  (RAM0_byte_en[i]),
  	   	 .addra(RAM0_wr_ADDR[i]),  // �������������λΪZ�������������  
  	   	 .dina (RAM0_wr_data[i]),
  	   	   	   	
  	   	 .addrb(RAM0_rd_ADDR[i]),
  	   	 .doutb(RAM0_rd_data[i])
  	   	 );

  	   end 
  endgenerate
  
  // batch ram 1 
  
  generate
  	for(i=0;i<BATCH;i=i+1)
  	   begin : batch_Ram1
  	   	user_ram_byte_en #(
  	   	 .RAM_DEPTH(FIN1+100),
  	   	 .RAM_WIDTH(AF*DATA_WIDTH)
  	   	 ) RAM_1
  	   	 (
  	   	 .clk(clk),    
  	   	 .rstn(rstn),
  	   	 .wea  (RAM1_byte_en[i]),
  	   	 .addra(RAM1_wr_ADDR[i]),  // �������������λΪZ�������������  
  	   	 .dina (RAM1_wr_data[i]),
  	   	   	   	
  	   	 .addrb(RAM1_rd_ADDR[i]),
  	   	 .doutb(RAM1_rd_data[i])
  	   	 );

  	   end 
  endgenerate
  
  
  generate                         
  	for(i=0;i<BATCH;i=i+1)         
  	   begin : batch_Ram2 
  	   	user_ram_byte_en #(
  	   	 .RAM_DEPTH(FIN2+100),
  	   	 .RAM_WIDTH(AF*DATA_WIDTH)
  	   	 ) RAM_2
  	   	 (
  	   	 .clk(clk), 
  	   	 .rstn(rstn),
  	   	 .wea  (RAM2_byte_en),
  	   	 .addra(RAM2_wr_ADDR),  // �������������λΪZ�������������  
  	   	 .dina (RAM2_wr_data[i]),
  	   	   	   	
  	   	 .addrb(RAM2_rd_ADDR),
  	   	 .doutb(RAM2_rd_data[i])
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
endmodule
