


%macro DeDup(dsname=, byvar= , duplevel=, nouni=);

/*=========================================
 ���ȥ�ؼ��𣨱������۲⣩����������ҪUNI,��ҪUNI��
 duplevel= REC|KEY
 nouni=1|0   ;  1: �ظ������棬һ��Ҳ��Ҫ
                0���ظ������棬ȡ��һ��
�������ݼ���dupout, nodupout,uniout
===========================================*/ 



%if  %upcase(&duplevel)=KEY  and  &nouni=0   %then %do;
   proc sort data=&dsname  nodupkey  dupout=dupout  out=nodupout;
   		by &byvar;
	run;
%end;

%if  %upcase(&duplevel)=KEY  and  &nouni=1   %then %do;
   proc sort data=&dsname nouniquekey    uniout=uniout ;
   		by &byvar;
	run;

	 data dupout;
	    set &dsname;
	run;
%end;

%if  %upcase(&duplevel)=REC and  &nouni=0  %then %do;
   proc sort data=&dsname noduprec     dupout=dupout  out=nodupout;
   		by &byvar;
	run;
%end;

%if  %upcase(&duplevel)=REC  and  &nouni=1   %then %do;
   proc sort data=&dsname nouniquerec   uniout=uniout ;
   		by &byvar;
	run;

	data dupout;
	    set &dsname;
	run;
%end;
%mend DeDup;

