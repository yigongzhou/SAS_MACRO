


%macro DeDup(dsname=, byvar= , duplevel=, nouni=);

/*========================================================================================
 Removing duplicated values based on variables, observations, and whether keep first values
 duplevel= REC|KEY
 nouni=1|0   ;  1: Remove all from duplicated 
                0：Keep first from duplicated
Output datasets：dupout, nodupout,uniout
=========================================================================================*/ 



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

