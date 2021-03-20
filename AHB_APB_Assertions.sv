/*Reference signals :

      HTRANS [1:0] ={IDLE =0,BUSY=1,NON_SEQ=2,SEQ=3};
      
      HBURST [2:0] ={SINGLE=0 ,INCR_BURST=1, WRAP_4=2, INCR_4=3 ,WRAP_8 =4,
                     INCR_8= 5, WRAP_16 =6, INCR =16};
                     
      HSIZE [2:0] ={ BYTE =0, HALF_WORD =1, WORD =2, DOUBLE_WORD =3, 4_WORD_LINE=4, 8_WORD_LINE =5};
      
*/

//1) Check WRAP_4_BYTE

property check_wrap4_byte;
  @(posedge clk) disable iff(!rst_n)
  
  ((HTRANS==3) && (HBURST==2) && (HSIZE==0) && ($past(HREADY)) && (HTRANS!=1))|->
  (HADDR[1:0]==$past(HADDR[1:0]) +2'b1) && (HADDR[31:2] == $past(HADDR[31:2]));
  
endproperty

//2) Check WRAP_4_HALF_WORD

property check_wrap4_halfword;
  @(posedge clk) disable iff(!rst_n)
  
  ((HTRANS==3) && (HBURST=2) && (HSIZE==1) && ($past(HREADY)) && ($past(HTRANS)!=1))|->
  (HADDR[2:1]==$past(HADDR[2:1] +2'b1)) && (HADDR[31:3] ==$past(HADDR[31:3]));
endproperty

//3) Check WRAP_4_WORD

property check_wrap4_word;
  @(posedge clk) disable iff(!rst_n)
  
  ((HTRANS==3) && (HBURST==2) && (HSIZE==2) && ($past(HREADY)) && (HTRANS!=1))|->
  (HADDR[3:2]==$past(HADDR[3:2]) +2'b1) && (HADDR[31:4] == $past(HADDR[31:4]));
  
endproperty


//4) Check WRAP_8_BYTE

property check_wrap8_word;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==3) &&( HBURST==4) && (HSIZE==0) && ($past(HREADY)) && ($past(HTRANS)!=1)|-> 
  (HADDR[2:0] == $past(HADDR[2:0]) +3'b1) && (HADDR[31:3] ==$past(HADDR[31:3]));
  
endproperty

//5) Check WRAP_8_HALF_WORD

property check_wrap8_word;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==3) &&( HBURST==4) && (HSIZE==1) && ($past(HREADY)) && ($past(HTRANS)!=1)|-> 
  (HADDR[3:1] == $past(HADDR[3:1]) +3'b1) && (HADDR[31:5] ==$past(HADDR[31:5]));
  
endproperty


//6) Check WRAP_8_WORD

property check_wrap8_word;
  @(posedge clk) disable iff(!rst_n)
  
   (HTRANS==3) &&( HBURST==4) && (HSIZE==2) && ($past(HREADY)) && ($past(HTRANS)!=1)|-> 
  (HADDR[4:2] == $past(HADDR[4:2]) +3'b1) && (HADDR[31:5] ==$past(HADDR[31:5]));
  
endproperty



//7) Address Boundary Aligned HALFWORD

property check_boundary_halfword;
  @(posedge clk) disable iff(!rst_n)
  
  (HSIZE==1)|-> HADDR[0]== 1'b0;
  
endproperty

//8) Address Boundary Aligned WORD

property check_boundary_byte;
  @(posedge clk) disable iff(!rst_n)
  
  (HSIZE==2)|-> HADDR[1:0] ==2'b0;
endproperty

//9) Address boundary Aligned DOUBLE_WORD

property check_double_word;
  @(posedge clk) disable iff(!rst_n)
  
  (HSIZE==3)|-> HADDR[3:0] ==4'b0;
endproperty

//10) Check_KB_boundary

property check_KB_boundary;
  @(posedge clk) disable iff(!rst_n)
  (HTRANS==3) |-> HADDR[10:0] != 11'b1000_0000 ;
endproperty

//11) Check INCR_BURST_X

property check_incr_burst;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==3) && ((HSIZE==0)||(HSIZE==1)||(HSIZE==2)) && ($past(HREADY)) && ($past(HTRANS)!=1) |-> (HADDR ==$past(HADDR,1) + 2**HSIZE);
  
endproperty

//12) Check INCR/BURST SEQ ADDRESS

property check burst_seq_add;
  @(posedge clk) disable iff(!rst_n)
  (HBURST);
endproperty

//13) Zero_Wait OKAY RESP on IDLE

property check_okay_on_idle;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==0)|=> (HRESP==0);
endproperty

//14) Check stable_addr_write_on_busy

property busy_addr_write;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==1) && (HWRITE) ##1 (HTRANS!= 0)|=> ($past(HADDR,1)==$past(HADDR,2)) 
  && ($past(HWDATA,1)==$past(HWDATA,2));
  
endproperty

//15) Check stable_addr_read_on_busy

property busy_addr_read;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==1) && (!HWRITE) ##1 (HTRANS!=0) |=> ($past(HADDR,1)==$past(HADDR,2)) 
  && ($past(HRDATA,1)==$past(HRDATA,2));
  
  
endproperty

//16) Check NONSEQ SINGLE BURST NOT TERMINATED BY BUSY

property check_no_busy;
  @(posedge clk) disable iff(!rst_n)
  
  (HBURST==0)|=> (HTRANS!=1);
  
endproperty

//17) BUSY FOLLOWS IDLE

property check_busy_idle;
  @(posedge clk) disable iff(!rst_n)
  
  (HTRANS==1) ##1 (HTRANS==0)|-> ($past(HBURST,1)==1);
  
endproperty

//18) SINGLE LEN BURST followed by IDLE or NON-SEQ

property check_single_trans_non_seq;
  @(posedge clk) disable iff(!rst_n)
  
  (HBURST==0)|=> (HTRANS==2)||(HTRANS==1);
  
endproperty


//19) Check FIRST_SEQ_BEAT_NON_SEQ_FOLLOWS_SEQ

sequence burst_variety;
  (HBURST==2)||(HBURST==3) ||(HBURST==4) ||(HBURST==5) ||(HBURST==6) ||(HBURST==7)
  && (HREADY) && (HTRANS!=1);

endsequence

property first_burst_beat_nonseq;
  @(posedge clk) disable iff(!rst_n)
  
  burst_variety|-> (HTRANS==2) ##1 ((HTRANS==3) && (HTRANS!=0))[*1:$] ##0 (HTRANS!=3);
  
endproperty



//20) Two cycle ERROR REPONSE

property two_cycle_error;
  @(posedge clk) diable iff(!rst_n)
  (HRESP==1) ##1 (HRESP==1)|-> (HTRANS==0);
endproperty

  
  




  
  
                             


  
  






   
   
  

   

  



