libname wave5 '/home2/andrew/adolescent/twin/phase5/sasdata';
libname yigong '/accounts/students/yingongz/';

************************************************************************************;
**********QUICK ‘TABLE1’ with format using MACRO and ARRAY**************************;
************************************************************************************;

**Instruction**;
**1:Add all variable name in both the macro(varlist) and array(array varlist{*}) **;
**2:Define outcome variable and N in macro**;
**3:If a variable have multiple levels, list the variable names in array varlistmult {*}**;
**4:**;

**********************************************ADD VARIABLE NAMES IN BOTH MACRO AND ARRAY.(MACRO HERE)**********************************************************;
%let varlist= smkheavyn smkd_A smkd_b smkd_c smkd_e smkd_f smkd_g smkd_h
              smkd alc_ever alc_cur alc_binge_12 alc_freq alc_freq5m alc_freqbinge alc_quan alcd alcd_A alcd_b alcd_C alcd_D alcd_E alcd_F alcd_G
              maritals pmar depres black csanew physabuse pregn mjweek mjuse sexwobc eversex earlysex neglect natdis natdis16 accident accident16  witness witness16 attack attack16 threat threat16 later forcedsex rape molest adultfs adultmol sexvic adultrape adultsexvic
Wtage lost nogain lose5 lose10 disturb disturb1 disturb2 disturb3 amenor_l  amenor_s concern fatfear binge bingeloc binge3l freqbin lfreqbin binge4 binons lfbinons curbinge vomit4 lax diuretics diuretics4 
purge diet diet4 fast fast4 exercise exercise4 nonpurge comp comp4 purgeons bulbeh bulbeh2l eatfast tummyache lgamt alone guilty bed_sum bed_sxb edtx anorex4 
lanorex4 anorex4_x lanorex4_x bn4 bn4l ednarrow edbroad  purgeonly purgedx lpurgedx bed;

**outcome variable name**;
%LET outcome=overweight;

**N for non-outcome**;
%LET non_out=2077;

**N for outcome**;
%LET out=1341;
***************************************************************************************************************************************************;

**extract statistics for proc means**;
proc means data= yigong.w5  n sum mean max;
  class  &varlist/missing; 
  var &outcome;
  ways 1;
  output out = yigong.Pretable n=
                               sum=
                               mean= 
			       max= /autoname;
run;

data yigong.table (keep =&outcome._max variable levels &outcome._N &outcome._sum &outcome._mean nonexp_sum pct nonexp_pct ExpPct nonpct indexvar);
  set yigong.Pretable;

  length variable $ 20;
  length levels $ 20;
  length pct $ 8; 
  length exppct $ 15;
  length nonexp_pct $ 8;
  length nonpct $ 15;
****************************************VARIABLE NAMES NEED to BE CHANGED.(ARRAY HERE)*****************************************************************************************;
array varlist{*} smkheavyn smkd_A smkd_b smkd_c smkd_e smkd_f smkd_g smkd_h
              smkd alc_ever alc_cur alc_binge_12 alc_freq alc_freq5m alc_freqbinge alc_quan alcd alcd_A alcd_b alcd_C alcd_D alcd_E alcd_F alcd_G
              maritals pmar depres black csanew physabuse pregn mjweek mjuse sexwobc eversex earlysex neglect natdis natdis16 accident accident16  witness witness16 attack attack16 threat threat16 later forcedsex rape molest adultfs adultmol sexvic adultrape adultsexvic
Wtage lost nogain lose5 lose10 disturb disturb1 disturb2 disturb3 amenor_l  amenor_s concern fatfear binge bingeloc binge3l freqbin lfreqbin binge4 binons lfbinons curbinge vomit4 lax diuretics diuretics4 
purge diet diet4 fast fast4 exercise exercise4 nonpurge comp comp4 purgeons bulbeh bulbeh2l eatfast tummyache lgamt alone guilty bed_sum bed_sxb edtx anorex4 
lanorex4 anorex4_x lanorex4_x bn4 bn4l ednarrow edbroad  purgeonly purgedx lpurgedx bed;
;
**If a variable need multiple levels, list the variable names here**;
array varlistmult {*} alc_freq alc_freq5m alc_freqbinge alc_quan maritals 
binge3l binge4 vomit4 diuretics4 diet4 fast4 exercise4 comp4 bulbeh bulbeh2l bed_sum purgeonly;
****************************************************************************************************************************************************************;


do i=1 to dim(varlist);                             
    if varlist{i} ne . and varlist{i} ne 0 then do;
      variable = vname(varlist{i});
      levels= '';
      indexvar=i;
    end;
end;

do i=1 to dim(varlistmult);                               
    if varlistmult{i} ne . then do;
      variable = vname(varlistmult{i});
      levels= varlistmult{i};
      indexvar=i+dim(varlist);
    end;
end;
  

****************************************CHANGE THE DEPENDENT VARIABLE NAME.(smkpop_obese)*********************************************************;
  nonexp_sum=&outcome._N-&outcome._sum;

  pct=put((&outcome._sum/&out)*100,4.1);
  nonexp_pct=put((nonexp_sum/&non_out)*100,4.1);

  exppct=compress(put(&outcome._sum,comma4.),' ')||' '||'('||compress(pct,' ')||')';
  nonpct=compress(put(nonexp_sum,comma4.),' ')||' '||'('||compress(nonexp_pct,' ')||')';
run;
************************************************************************************************************************************************;
proc contents data=yigong.w5 out=yigong.label(keep=name label);
run;	
data yigong.label;
set yigong.label;
variable=name;
run;
proc sort data=yigong.table;
by variable;
run;
proc sort data=yigong.label nodupkey;
by variable;
run;

data yigong.table;
merge yigong.label yigong.table;
by variable;
run;

ods trace on;
ods output chisq = yigong.ChiData;
      
proc freq data= yigong.w5;

tables &outcome *(&varlist)/chisq;

run;
ods trace off;


data yigong.ChiData2 (keep = variable prob);
	set yigong.ChiData (where = (statistic = 'Chi-Square'));
	
	length variable $20;

	variable =scan(table,-1,' ');
	
	if prob gt 0.05 then prob= 888.88;
run;


proc sort data=yigong.table;
	by variable descending levels ;
run;

proc sort data=yigong.chidata2;
	by variable;
run;

data yigong.tableData;
	merge yigong.table (in = a)
	      yigong.Chidata2 (in=b);
	by variable;
if a;
run;


ods escapechar = '~';

option nodate nonumber orientation = landscape;

ods rtf file = '/accounts/students/yingongz/BasicRTF.rtf'  bodytitle;
*********************************Outcome name need to be changed in title****************************************************;
**Create final table**;
Proc report data = yigong.TableData nowd
 style(report) = {cellpadding = 1.25pt
 cellspacing = 0pt
 frame = hsides
 rules = groups}
 style(header) = {font = ("arial",11pt)
 background = white}
 style(column) = {font = ("arial",11pt)};


 column variable label levels exppct nonpct prob;

 define variable / "Variable" group 
 style(header) = {just = left}
 style(column) = {cellwidth = 1.5in};
 
 define label  /group  width=80
 Style(column) = {cellwidth = 1.5in};

 define levels / " "
 Style(column) = {cellwidth = 1.5in};

 define nonpct / "Non-obese/n (%)/(n = &non_out)" 
 style(column) = {just = right
 cellwidth = 1.25in
 rightmargin = .4in};

 define ExpPct / "Obese/n (%)/(n = &out)"
 style(column) = {cellwidth = 1.25in
 just = right
 rightmargin = .25in} ;

 define prob / "p-value~{super 1}" group
 style(column) = {just = center};

/* compute before variable;
 line ' ';*/

 endcomp;
/* Inline formatting and title/footnote text on the same statement
line may be written in separate quote groups */

Title '~S={leftmargin = 2.25in font = ("arial",11pt) just = left}'
 'Table 1: Characteristics of Subjects';
footnote '~S={leftmargin = 2.25in font = ("arial",9pt) just = left}~{super 1}'
 'Chi-square test for association';
run;
ods rtf close;
title;
footnote;









