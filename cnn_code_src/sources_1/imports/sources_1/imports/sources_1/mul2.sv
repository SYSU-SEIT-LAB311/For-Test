`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//�˷�������д��ģ����Ϊ��ָʾvivado�ۺϳ�dsp
//////////////////////////////////////////////////////////////////////////////////


(* use_dsp = "yes" *) module mul2#(
parameter DATA_WIDTH=8,
parameter SUM_COUNT =5
)(
  input logic [DATA_WIDTH-1:0] ain,
  input logic [DATA_WIDTH-1:0] bin,
  output logic [2*DATA_WIDTH-1+SUM_COUNT:0] cout
    );
    
  assign cout=$signed(ain)* $signed(bin); 
    
endmodule
