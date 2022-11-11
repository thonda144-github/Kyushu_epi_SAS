/* 
 EXAMPLE: �ǡ������å�̾
 X: �����ѿ�(�Х����ޡ������ߤ�����)
 X_cat: X��4ʬ��
 Y: �����ȥ���(Ϣ³��)
 Y_cat: Y��2���ѿ��ˤ������
 
*/

DATA EXAMPLE;
call streaminit(1234);
  do i=1 to 12000;
    x=rand('normal',1,1); /*mean=0, sd=1������ʬ�ۤ����*/;
    e=rand('normal',0,2); /*mean=0, sd=3������ʬ�ۤ����*/;
  output;
  end;

DATA EXAMPLE; SET EXAMPLE;
	x=exp(0.6*x); /* �Ĥޤ��� */;
	  
	y=10+0.8*x+e; /* ���� 10, x�β󵢷���1�Υǡ������� */;
	  
	y_cat=0; 
		if y>=12 then y_cat=1; /*����Ͷ᤯��Ŭ����ʬ��*/;

proc means mean std min P25 median P75 max;
	var x y;

* 4ʬ�̤�ʬ����ʥ��ƥ���ϼ�ưŪ��0,1,2,3���ֹ椬�������;
PROC RANK GROUPS=4 OUT=EXAMPLE;
	VAR X;
	RANKS X_cat;

proc means min P25 median P75 max;
	class X_cat;
	var x;

DATA EXAMPLE; SET EXAMPLE;
*���ߡ��ѿ�����;
X_Q1=0; X_Q2=0;	X_Q3=0; X_Q4=0;
	if X_cat=0 	then do; X_Q1=1; X_Q2=0; X_Q3=0; X_Q4=0; end;
	if X_cat=1	then do; X_Q1=0; X_Q2=1; X_Q3=0; X_Q4=0; end;
	if X_cat=2 	then do; X_Q1=0; X_Q2=0; X_Q3=1; X_Q4=0; end;
	if X_cat=3 	then do; X_Q1=0; X_Q2=0; X_Q3=0; X_Q4=1; end;
	

proc sgscatter;
	matrix x y_cat/diagonal=(histogram kernel);

*OR�����;
proc logistic descending;
	model y_cat=x_cat;

*�����������;
proc logistic descending;
	class x_cat(ref='0')/param=ref;
	model y_cat=x_cat;

proc freq;
	tables y_cat*x_cat/trend;



proc logistic descending;
	model y_cat=x_q2 x_q3 x_q4;