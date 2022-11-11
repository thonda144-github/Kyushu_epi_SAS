/* 
 EXAMPLE: データセット名
 X: 説明変数(バイオマーカーみたいな)
 X_cat: Xの4分位
 Y: アウトカム(連続量)
 Y_cat: Yを2値変数にしたもの
 
*/

DATA EXAMPLE;
call streaminit(1234);
  do i=1 to 12000;
    x=rand('normal',1,1); /*mean=0, sd=1の正規分布の乱数*/;
    e=rand('normal',0,2); /*mean=0, sd=3の正規分布の乱数*/;
  output;
  end;

DATA EXAMPLE; SET EXAMPLE;
	x=exp(0.6*x); /* 歪ませる */;
	  
	y=10+0.8*x+e; /* 切片 10, xの回帰係数1のデータ生成 */;
	  
	y_cat=0; 
		if y>=12 then y_cat=1; /*中央値近くで適当に分割*/;

proc means mean std min P25 median P75 max;
	var x y;

* 4分位に分ける（カテゴリは自動的に0,1,2,3の番号が振られる）;
PROC RANK GROUPS=4 OUT=EXAMPLE;
	VAR X;
	RANKS X_cat;

proc means min P25 median P75 max;
	class X_cat;
	var x;

DATA EXAMPLE; SET EXAMPLE;
*ダミー変数を作る;
X_Q1=0; X_Q2=0;	X_Q3=0; X_Q4=0;
	if X_cat=0 	then do; X_Q1=1; X_Q2=0; X_Q3=0; X_Q4=0; end;
	if X_cat=1	then do; X_Q1=0; X_Q2=1; X_Q3=0; X_Q4=0; end;
	if X_cat=2 	then do; X_Q1=0; X_Q2=0; X_Q3=1; X_Q4=0; end;
	if X_cat=3 	then do; X_Q1=0; X_Q2=0; X_Q3=0; X_Q4=1; end;
	

proc sgscatter;
	matrix x y_cat/diagonal=(histogram kernel);

*ORを求める;
proc logistic descending;
	model y_cat=x_cat;

*傾向性を求める;
proc logistic descending;
	class x_cat(ref='0')/param=ref;
	model y_cat=x_cat;

proc freq;
	tables y_cat*x_cat/trend;



proc logistic descending;
	model y_cat=x_q2 x_q3 x_q4;