`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/* 
// Create Date: 2019/12/23 18:56:53
// �����top ������13�� vgg ����� ����ģ�鲻�������棬��Ҫ������VGG_CONV��
// 1. �����м�ӿ�
   2. ʵ����ÿ��Ӳ��
   3. ģ��ddr4 �ڴ�����뻺�棨�߼����ǲ�ͨ�ģ���û������д�˼��䣩
*/
//////////////////////////////////////////////////////////////////////////////////


module VGG_CONV_SYN //�����ݷ��治�������ģ�飬��VGG_CONV
(  conv_top.row_buffer_in conv_data_in,     //conv1 feature map����
   conv_top.pe_out       conv_result_out,   //conv13 ����������
   
   input logic [127:0] fifo_in,             //ģ������dma buffer ���룬�ٶԽӷ���conv1-conv13��weight in���ⲿ�ֹ�����Ҫ����DDR4 ��û��
   input logic fifo_wren,
  
   input logic clkin,
   input logic rstn 
    );
import parameter_package::*;                //ģ�;�������в���������д�ڵ�����һ��package�ļ��С�
logic clk;
assign clk=clkin; 
// clk_wiz_0 u_clk1  //�ۺ���ʱ�ӹ���������vgg16�����ǣ�ȡ�����������ʹ�á�
// (
// .clkin(clkin),
// .resetn(rstn),
// .clk_out1(clk)
// );
  

conv_top #    //����ӿڣ�֮ǰ������ʹ��gennerate��䶨�壬����һֱ��������û�м����о������˱�����һ��������        
  	 (                     
  	 .Wh(CONV_Wh[1]),     
  	 .Iw(CONV_Iw[1]),     
     .Ww(CONV_Ww[1])      
     )                     
     conv_interface_1 (           
     );                    
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[2]),     
  	 .Iw(CONV_Iw[2]),     
     .Ww(CONV_Ww[2])      
     )                     
     conv_interface_2 (           
     ); 
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[3]),     
  	 .Iw(CONV_Iw[3]),     
     .Ww(CONV_Ww[3])      
     )                     
     conv_interface_3 (           
     ); 
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[4]),     
  	 .Iw(CONV_Iw[4]),     
     .Ww(CONV_Ww[4])      
     )                     
     conv_interface_4 (           
     ); 
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[5]),     
  	 .Iw(CONV_Iw[5]),     
     .Ww(CONV_Ww[5])      
     )                     
     conv_interface_5 (           
     ); 
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[6]),     
  	 .Iw(CONV_Iw[6]),     
     .Ww(CONV_Ww[6])      
     )                     
     conv_interface_6 (           
     );      
conv_top #            
  	 (                     
  	 .Wh(CONV_Wh[7]),     
  	 .Iw(CONV_Iw[7]),     
     .Ww(CONV_Ww[7])      
     )                     
     conv_interface_7 (           
     );      
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[8]),           
  	 .Iw(CONV_Iw[8]),           
     .Ww(CONV_Ww[8])            
     )                          
     conv_interface_8 (         
        
     );                         
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[9]),           
  	 .Iw(CONV_Iw[9]),           
     .Ww(CONV_Ww[9])            
     )                          
     conv_interface_9 (         
        
     );                         
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[10]),           
  	 .Iw(CONV_Iw[10]),           
     .Ww(CONV_Ww[10])            
     )                          
     conv_interface_10 (         
        
     );                         
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[11]),           
  	 .Iw(CONV_Iw[11]),           
     .Ww(CONV_Ww[11])            
     )                          
     conv_interface_11 (         
        
     );                         
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[12]),           
  	 .Iw(CONV_Iw[12]),           
     .Ww(CONV_Ww[12])            
     )                          
     conv_interface_12 (         
        
     );                         
conv_top #                      
  	 (                          
  	 .Wh(CONV_Wh[13]),           
  	 .Iw(CONV_Iw[13]),           
     .Ww(CONV_Ww[13])            
     )                          
     conv_interface_13 (         
        
     );                         
   
    
  //�����һ��
  //�����0 ������͵�һ�����
  //��0������ǹ� writer ģ���ȡpe out�����ã�WH��IW�ȣ��������ܲ�ȫ���ϣ�
  //��һ������ṩ����������ģ�顣  
   conv #(
    .DATA_WIDTH       ( DATA_WIDTH       ),
    .K                ( K                ),
    .S                ( S                ),
    .ADDR_WIDTH       ( ADDR_WIDTH       ),
    .ROW_WIDTH        ( ROW_WIDTH        ),
    .PRECISION        ( PRECISION        ),
            
    .LAST_C           ( CONV_C[0]          ),
    .LAST_N           ( CONV_N[0]          ),
    .LAST_Wh          ( CONV_Wh[0]         ),
    .LAST_Ww          ( CONV_Ww[0]         ),
    .LAST_Ih          ( CONV_Ih[0]         ),
    .LAST_Iw          ( CONV_Iw[0]         ),
    .LAST_Bi          ( CONV_BI[0]         ),
    .REAL_HINT        ( CONV_REAL_HOUT[1]  ),
    .REAL_HOUT        ( CONV_REAL_HINT[1]  ),
    .NEXT_C           ( CONV_C[1]         ),
    .NEXT_N           ( CONV_N[1]         ),
    .NEXT_Wh          ( CONV_Wh[1]        ),
    .NEXT_Ww          ( CONV_Ww[1]        ),
    .NEXT_Ih          ( CONV_Ih[1]        ),
    .NEXT_Iw          ( CONV_Iw[1]        ),
    .NEXT_Bi          ( CONV_BI[1]        ))
    
                      u_conv_1 (
     .pe_weight_data_in(conv_interface_1.pe_weight_in),   //���� ���㵥Ԫ�� weight
     .pe_data_out      (conv_interface_1.pe_out),         //conv1 ���㵥Ԫ�����                    
     .row_data_in      (conv_data_in) ,                   //conv1 ��������
     .clk(clk),
     .rstn(rstn)
); 
 //ͬ��   
      conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C[1]          ),              
    .LAST_N           ( CONV_N[1]          ),              
    .LAST_Wh          ( CONV_Wh[1]         ),              
    .LAST_Ww          ( CONV_Ww[1]         ),              
    .LAST_Ih          ( CONV_Ih[1]         ),              
    .LAST_Iw          ( CONV_Iw[1]         ),              
    .LAST_Bi          ( CONV_BI[1]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[2]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[2]  ),              
    .NEXT_C           ( CONV_C[2]         ),               
    .NEXT_N           ( CONV_N[2]         ),               
    .NEXT_Wh          ( CONV_Wh[2]        ),               
    .NEXT_Ww          ( CONV_Ww[2]        ),               
    .NEXT_Ih          ( CONV_Ih[2]        ),               
    .NEXT_Iw          ( CONV_Iw[2]        ),               
    .NEXT_Bi          ( CONV_BI[2]        ))               
                      u_conv_2 (                          
     .pe_weight_data_in(conv_interface_2.pe_weight_in),   
     .pe_data_out      (conv_interface_2.pe_out),         
     .row_data_in      (conv_interface_1.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
); 
 // ͬ�ϣ���������һ�㣬�����ݽ��ն�������pooling ģ�顣
 // �൱�ڵڶ��������poolingģ�顣
 // ������Ϊ�˷�����matlab���в��ԣ�û����relu�����Ҫ���Ļ�����row bufferд��ʱ��һ���жϴ���Ϳ����ˣ��ܼ򵥡���relu)
   conv_pooling #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C[2]          ),              
    .LAST_N           ( CONV_N[2]          ),              
    .LAST_Wh          ( CONV_Wh[2]         ),              
    .LAST_Ww          ( CONV_Ww[2]         ),              
    .LAST_Ih          ( CONV_Ih[2]         ),              
    .LAST_Iw          ( CONV_Iw[2]         ),              
    .LAST_Bi          ( CONV_BI[2]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[3]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[3]  ),                                                                     
    .NEXT_C           ( CONV_C[3]         ),               
    .NEXT_N           ( CONV_N[3]         ),                   
    .NEXT_Wh          ( CONV_Wh[3]        ),               
    .NEXT_Ww          ( CONV_Ww[3]        ),               
    .NEXT_Ih          ( CONV_Ih[3]        ),               
    .NEXT_Iw          ( CONV_Iw[3]        ),               
    .NEXT_Bi          ( CONV_BI[3]        ))               
                      u_conv_pool_3 (                          
     .pe_weight_data_in(conv_interface_3.pe_weight_in),   
     .pe_data_out      (conv_interface_3.pe_out),         
     .row_data_in      (conv_interface_2.row_buffer_in),      
     .clk(clk),
     .rstn(rstn)
);                                                         
     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [3]          ),              
    .LAST_N           ( CONV_N [3]          ),              
    .LAST_Wh          ( CONV_Wh[3]         ),              
    .LAST_Ww          ( CONV_Ww[3]         ),              
    .LAST_Ih          ( CONV_Ih[3]         ),              
    .LAST_Iw          ( CONV_Iw[3]         ),              
    .LAST_Bi          ( CONV_BI[3]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[4]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[4]  ),              
    .NEXT_C           ( CONV_C        [4]         ),               
    .NEXT_N           ( CONV_N        [4]         ),               
    .NEXT_Wh          ( CONV_Wh       [4]        ),               
    .NEXT_Ww          ( CONV_Ww       [4]        ),               
    .NEXT_Ih          ( CONV_Ih       [4]        ),               
    .NEXT_Iw          ( CONV_Iw       [4]        ),               
    .NEXT_Bi          ( CONV_BI       [4]        ))               
                      u_conv_4 (                          
     .pe_weight_data_in(conv_interface_4.pe_weight_in),   
     .pe_data_out      (conv_interface_4.pe_out),         
     .row_data_in      (conv_interface_3.row_buffer_in) ,  
     .clk(clk),
     .rstn(rstn)
);  
   conv_pooling #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [4]          ),              
    .LAST_N           ( CONV_N [4]          ),              
    .LAST_Wh          ( CONV_Wh[4]         ),              
    .LAST_Ww          ( CONV_Ww[4]         ),              
    .LAST_Ih          ( CONV_Ih[4]         ),              
    .LAST_Iw          ( CONV_Iw[4]         ),              
    .LAST_Bi          ( CONV_BI[4]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[5]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[5]  ),                                                                     
    .NEXT_C           ( CONV_C        [5]         ),               
    .NEXT_N           ( CONV_N        [5]         ),                   
    .NEXT_Wh          ( CONV_Wh       [5]        ),               
    .NEXT_Ww          ( CONV_Ww       [5]        ),               
    .NEXT_Ih          ( CONV_Ih       [5]        ),               
    .NEXT_Iw          ( CONV_Iw       [5]        ),               
    .NEXT_Bi          ( CONV_BI       [5]        ))               
                      u_conv_pool_5 (                          
     .pe_weight_data_in(conv_interface_5.pe_weight_in),   
     .pe_data_out      (conv_interface_5.pe_out),         
     .row_data_in      (conv_interface_4.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [5]          ),              
    .LAST_N           ( CONV_N [5]          ),              
    .LAST_Wh          ( CONV_Wh[5]         ),              
    .LAST_Ww          ( CONV_Ww[5]         ),              
    .LAST_Ih          ( CONV_Ih[5]         ),              
    .LAST_Iw          ( CONV_Iw[5]         ),              
    .LAST_Bi          ( CONV_BI[5]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[6]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[6]  ),              
    .NEXT_C           ( CONV_C        [6]         ),               
    .NEXT_N           ( CONV_N        [6]         ),               
    .NEXT_Wh          ( CONV_Wh       [6]        ),               
    .NEXT_Ww          ( CONV_Ww       [6]        ),               
    .NEXT_Ih          ( CONV_Ih       [6]        ),               
    .NEXT_Iw          ( CONV_Iw       [6]        ),               
    .NEXT_Bi          ( CONV_BI       [6]        ))               
                      u_conv_6 (                          
     .pe_weight_data_in(conv_interface_6.pe_weight_in),   
     .pe_data_out      (conv_interface_6.pe_out),         
     .row_data_in      (conv_interface_5.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  
     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [6]          ),              
    .LAST_N           ( CONV_N [6]          ),              
    .LAST_Wh          ( CONV_Wh[6]         ),              
    .LAST_Ww          ( CONV_Ww[6]         ),              
    .LAST_Ih          ( CONV_Ih[6]         ),              
    .LAST_Iw          ( CONV_Iw[6]         ),              
    .LAST_Bi          ( CONV_BI[6]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[7]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[7]  ),              
    .NEXT_C           ( CONV_C        [7]         ),               
    .NEXT_N           ( CONV_N        [7]         ),               
    .NEXT_Wh          ( CONV_Wh       [7]        ),               
    .NEXT_Ww          ( CONV_Ww       [7]        ),               
    .NEXT_Ih          ( CONV_Ih       [7]        ),               
    .NEXT_Iw          ( CONV_Iw       [7]        ),               
    .NEXT_Bi          ( CONV_BI       [7]        ))               
                      u_conv_7 (                          
     .pe_weight_data_in(conv_interface_7.pe_weight_in),   
     .pe_data_out      (conv_interface_7.pe_out),         
     .row_data_in      (conv_interface_6.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  
                              
     conv_pooling #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [7]          ),              
    .LAST_N           ( CONV_N [7]          ),              
    .LAST_Wh          ( CONV_Wh[7]         ),              
    .LAST_Ww          ( CONV_Ww[7]         ),              
    .LAST_Ih          ( CONV_Ih[7]         ),              
    .LAST_Iw          ( CONV_Iw[7]         ),              
    .LAST_Bi          ( CONV_BI[7]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[8]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[8]  ),              
    .NEXT_C           ( CONV_C        [8]         ),               
    .NEXT_N           ( CONV_N        [8]         ),               
    .NEXT_Wh          ( CONV_Wh       [8]        ),               
    .NEXT_Ww          ( CONV_Ww       [8]        ),               
    .NEXT_Ih          ( CONV_Ih       [8]        ),               
    .NEXT_Iw          ( CONV_Iw       [8]        ),               
    .NEXT_Bi          ( CONV_BI       [8]        ))               
                      u_conv_pool_8 (                          
     .pe_weight_data_in(conv_interface_8.pe_weight_in),   
     .pe_data_out      (conv_interface_8.pe_out),         
     .row_data_in      (conv_interface_7.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [8]          ),              
    .LAST_N           ( CONV_N [8]          ),              
    .LAST_Wh          ( CONV_Wh[8]         ),              
    .LAST_Ww          ( CONV_Ww[8]         ),              
    .LAST_Ih          ( CONV_Ih[8]         ),              
    .LAST_Iw          ( CONV_Iw[8]         ),              
    .LAST_Bi          ( CONV_BI[8]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[9]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[9]  ),              
    .NEXT_C           ( CONV_C        [9]         ),               
    .NEXT_N           ( CONV_N        [9]         ),               
    .NEXT_Wh          ( CONV_Wh       [9]        ),               
    .NEXT_Ww          ( CONV_Ww       [9]        ),               
    .NEXT_Ih          ( CONV_Ih       [9]        ),               
    .NEXT_Iw          ( CONV_Iw       [9]        ),               
    .NEXT_Bi          ( CONV_BI       [9]        ))               
                      u_conv_9 (                          
     .pe_weight_data_in(conv_interface_9.pe_weight_in),   
     .pe_data_out      (conv_interface_9.pe_out),         
     .row_data_in      (conv_interface_8.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [9]          ),              
    .LAST_N           ( CONV_N [9]          ),              
    .LAST_Wh          ( CONV_Wh[9]         ),              
    .LAST_Ww          ( CONV_Ww[9]         ),              
    .LAST_Ih          ( CONV_Ih[9]         ),              
    .LAST_Iw          ( CONV_Iw[9]         ),              
    .LAST_Bi          ( CONV_BI[9]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[10]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[10]  ),              
    .NEXT_C           ( CONV_C        [10]         ),               
    .NEXT_N           ( CONV_N        [10]         ),               
    .NEXT_Wh          ( CONV_Wh       [10]        ),               
    .NEXT_Ww          ( CONV_Ww       [10]        ),               
    .NEXT_Ih          ( CONV_Ih       [10]        ),               
    .NEXT_Iw          ( CONV_Iw       [10]        ),               
    .NEXT_Bi          ( CONV_BI       [10]        ))               
                      u_conv_10 (                          
     .pe_weight_data_in(conv_interface_10.pe_weight_in),   
     .pe_data_out      (conv_interface_10.pe_out),         
     .row_data_in      (conv_interface_9.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv_pooling #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [10]          ),              
    .LAST_N           ( CONV_N [10]          ),              
    .LAST_Wh          ( CONV_Wh[10]         ),              
    .LAST_Ww          ( CONV_Ww[10]         ),              
    .LAST_Ih          ( CONV_Ih[10]         ),              
    .LAST_Iw          ( CONV_Iw[10]         ),              
    .LAST_Bi          ( CONV_BI[10]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[11]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[11]  ),              
    .NEXT_C           ( CONV_C        [11]         ),               
    .NEXT_N           ( CONV_N        [11]         ),               
    .NEXT_Wh          ( CONV_Wh       [11]        ),               
    .NEXT_Ww          ( CONV_Ww       [11]        ),               
    .NEXT_Ih          ( CONV_Ih       [11]        ),               
    .NEXT_Iw          ( CONV_Iw       [11]        ),               
    .NEXT_Bi          ( CONV_BI       [11]        ))               
                      u_conv_pool_11 (                          
     .pe_weight_data_in(conv_interface_11.pe_weight_in),   
     .pe_data_out      (conv_interface_11.pe_out),         
     .row_data_in      (conv_interface_10.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [11]          ),              
    .LAST_N           ( CONV_N [11]          ),              
    .LAST_Wh          ( CONV_Wh[11]         ),              
    .LAST_Ww          ( CONV_Ww[11]         ),              
    .LAST_Ih          ( CONV_Ih[11]         ),              
    .LAST_Iw          ( CONV_Iw[11]         ),              
    .LAST_Bi          ( CONV_BI[11]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[12]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[12]  ),              
    .NEXT_C           ( CONV_C        [12]         ),               
    .NEXT_N           ( CONV_N        [12]         ),               
    .NEXT_Wh          ( CONV_Wh       [12]        ),               
    .NEXT_Ww          ( CONV_Ww       [12]        ),               
    .NEXT_Ih          ( CONV_Ih       [12]        ),               
    .NEXT_Iw          ( CONV_Iw       [12]        ),               
    .NEXT_Bi          ( CONV_BI       [12]        ))               
                      u_conv_12 (                          
     .pe_weight_data_in(conv_interface_12.pe_weight_in),   
     .pe_data_out      (conv_interface_12.pe_out),         
     .row_data_in      (conv_interface_11.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  

     conv #(                                                
    .DATA_WIDTH       ( DATA_WIDTH       ),               
    .K                ( K                ),               
    .S                ( S                ),               
    .ADDR_WIDTH       ( ADDR_WIDTH       ),               
    .ROW_WIDTH        ( ROW_WIDTH        ),               
    .PRECISION        ( PRECISION        ),               
                                                          
    .LAST_C           ( CONV_C [12]          ),              
    .LAST_N           ( CONV_N [12]          ),              
    .LAST_Wh          ( CONV_Wh[12]         ),              
    .LAST_Ww          ( CONV_Ww[12]         ),              
    .LAST_Ih          ( CONV_Ih[12]         ),              
    .LAST_Iw          ( CONV_Iw[12]         ),              
    .LAST_Bi          ( CONV_BI[12]         ),              
    .REAL_HINT        ( CONV_REAL_HOUT[13]  ),              
    .REAL_HOUT        ( CONV_REAL_HINT[13]  ),              
    .NEXT_C           ( CONV_C        [13]         ),               
    .NEXT_N           ( CONV_N        [13]         ),               
    .NEXT_Wh          ( CONV_Wh       [13]        ),               
    .NEXT_Ww          ( CONV_Ww       [13]        ),               
    .NEXT_Ih          ( CONV_Ih       [13]        ),               
    .NEXT_Iw          ( CONV_Iw       [13]        ),               
    .NEXT_Bi          ( CONV_BI       [13]        ))               
                      u_conv_13 (                          
     .pe_weight_data_in(conv_interface_13.pe_weight_in),   
     .pe_data_out      (conv_result_out),         
     .row_data_in      (conv_interface_12.row_buffer_in),   
     .clk(clk),
     .rstn(rstn)
);  




                              
                              
                              
                              

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
// ģ��ddr4�������ݴ���ͻ��棬��һ��û����ֻ�ǵ���ɨ�踳ֵ���߼����ǲ���ȷ��
 (* max_fanout = "10" *)  logic [4:0] count,count_13;   
  always_ff@(posedge clk or negedge rstn)
  begin 
  	if (rstn==0)
  		count<=0;
  	else 
  	begin 
  		count<=count+1;  
  		count_13<=(count+1)%13;
  		 conv_interface_1.weight_buffer_din<='0;
  		 conv_interface_2.weight_buffer_din<='0;
  		 conv_interface_3.weight_buffer_din<='0;
  		 conv_interface_4.weight_buffer_din<='0;
  		 conv_interface_5.weight_buffer_din<='0;
  		 conv_interface_6.weight_buffer_din<='0;
  		 conv_interface_7.weight_buffer_din<='0;
  		 conv_interface_8.weight_buffer_din<='0;
  		 conv_interface_9.weight_buffer_din<='0;
  		conv_interface_10.weight_buffer_din<='0;
  		conv_interface_11.weight_buffer_din<='0;
  		conv_interface_12.weight_buffer_din<='0;
  		conv_interface_13.weight_buffer_din<='0;
  		 conv_interface_1.weight_buffer_wren<=0;
  		 conv_interface_2.weight_buffer_wren<=0;
  		 conv_interface_3.weight_buffer_wren<=0;
  		 conv_interface_4.weight_buffer_wren<=0;
  		 conv_interface_5.weight_buffer_wren<=0;
  		 conv_interface_6.weight_buffer_wren<=0;
  		 conv_interface_7.weight_buffer_wren<=0;
  		 conv_interface_8.weight_buffer_wren<=0;
  		 conv_interface_9.weight_buffer_wren<=0;
  		conv_interface_10.weight_buffer_wren<=0;
  		conv_interface_11.weight_buffer_wren<=0;
  		conv_interface_12.weight_buffer_wren<=0;
  		conv_interface_13.weight_buffer_wren<=0;
				
      case(count%13)
      	 1   : begin  conv_interface_1.weight_buffer_din<={'1,fifo_in}; conv_interface_1.weight_buffer_wren<=fifo_wren;   end
         2   : begin  conv_interface_2.weight_buffer_din<={'1,fifo_in}; conv_interface_2.weight_buffer_wren<=fifo_wren;   end
         3   : begin  conv_interface_3.weight_buffer_din<={'1,fifo_in}; conv_interface_3.weight_buffer_wren<=fifo_wren;   end
         4   : begin  conv_interface_4.weight_buffer_din<={'1,fifo_in}; conv_interface_4.weight_buffer_wren<=fifo_wren;   end
         5   : begin  conv_interface_5.weight_buffer_din<={'1,fifo_in}; conv_interface_5.weight_buffer_wren<=fifo_wren;   end
         6   : begin  conv_interface_6.weight_buffer_din<={'1,fifo_in}; conv_interface_6.weight_buffer_wren<=fifo_wren;   end
         7   : begin  conv_interface_7.weight_buffer_din<={'1,fifo_in}; conv_interface_7.weight_buffer_wren<=fifo_wren;   end
         8   : begin  conv_interface_8.weight_buffer_din<={'1,fifo_in}; conv_interface_8.weight_buffer_wren<=fifo_wren;   end
         9   : begin  conv_interface_9.weight_buffer_din<={'1,fifo_in}; conv_interface_9.weight_buffer_wren<=fifo_wren;   end
         10  : begin conv_interface_10.weight_buffer_din<={'1,fifo_in};conv_interface_10.weight_buffer_wren<=fifo_wren;   end
         11  : begin conv_interface_11.weight_buffer_din<={'1,fifo_in};conv_interface_11.weight_buffer_wren<=fifo_wren;   end
         12  : begin conv_interface_12.weight_buffer_din<={'1,fifo_in};conv_interface_12.weight_buffer_wren<=fifo_wren;   end
         13  : begin conv_interface_13.weight_buffer_din<={'1,fifo_in};conv_interface_13.weight_buffer_wren<=fifo_wren;   end
      endcase
    end 
  end 
  
         
    
endmodule
