libname CCFD "C:\Users\shrey\Desktop\MY GITHUB PROJECTS\Credit_Card_Fraud";

PROC IMPORT OUT= CCFD.EDA_CCFD 
            DATAFILE= "C:\Users\shrey\Downloads\PS_20174392719_149120443
9457_log.csv\PS_20174392719_1491204439457_log.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
**Summary of the dataset;
proc contents data=Ccfd.Eda_ccfd;
run;

** Univariate analysis on the type, fraud and the isflagged fraud variables;
Proc freq data=Ccfd.Eda_ccfd;
tables type isFraud isFlaggedFraud;
run;

proc chart data=Ccfd.Eda_ccfd;
vbar type isFraud isFlaggedFraud/ discrete type=freq;
run;
quit;

*****Datasets with fraud and flagged fraud rows;
Data Ccfd.Fraud;
set Ccfd.Eda_ccfd;
if isFraud=1;
run;

Data Ccfd.FlaggedFraud;
set Ccfd.Eda_ccfd;
if isFlaggedFraud=1;
run;

**Having a look at types again in these datasets;
Proc freq data=CCFD.Fraud;
tables type;
run;
proc chart data=Ccfd.Fraud;
vbar type/ discrete type=freq;
run;
quit;
**We observe here that all the fraud cases belongs to either Cash_out or Tranfer type;

Proc freq data=CCFD.FlaggedFraud;
tables type;
run;
proc chart data=Ccfd.FlaggedFraud;
vbar type/ discrete type=freq;
run;
quit;
**We observe here that all the flagged fraud cases belongs to the tranfer type;

**Standardising and normalising the data and Droping redundant columns like nameOrig and nameDest;
Data Ccfd.WithBinaries;
set Ccfd.Eda_ccfd;
if type="CASH_IN" then CASH_IN_TYPE=1;
				  else CASH_IN_TYPE=0;
if type="CASH_OUT" then CASH_OUT_TYPE=1;
				  else CASH_OUT_TYPE=0;
if type="DEBIT" then DEBIT_TYPE=1;
				  else DEBIT_TYPE=0;
if type="PAYMENT" then PAYMENT_TYPE=1;
				  else PAYMENT_TYPE=0;
if type="TRANSFER" then TRANSFER_TYPE=1;
				  else TRANSFER_TYPE=0;
Drop type nameOrig NameDest;
run;

proc standard Data=Ccfd.WithBinaries mean=0 std=1 out=Ccfd.StndWithBin;
var amount oldbalanceOrg newbalanceOrig oldbalanceDest newbalanceDest;
run;

**Having a look at the data before we proceed;
**Macros available in the file names macro.sas
%FreqReport(Ccfd.StndWithBin);
options mprint;

**Bivariate analysis for the numerical columns;
**Step vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,step,isFraud);
options nomprint;

**amount vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,amount,isFraud);
options nomprint;

**oldbalanceOrg vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,oldbalanceOrg,isFraud);
options nomprint;

**newbalanceOrig vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,newbalanceOrig,isFraud);
options nomprint;

**oldbalanceDest vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,oldbalanceDest,isFraud);
options nomprint;

**newbalanceDest vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,newbalanceDest,isFraud);
options nomprint;

**isFlaggedFraud vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,isFlaggedFraud,isFraud);
options nomprint;

**CASH_IN_TYPE vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,CASH_IN_TYPE,isFraud);
options nomprint;

**CASH_OUT_TYPE vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,CASH_OUT_TYPE,isFraud);
options nomprint;

**DEBIT_TYPE vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,DEBIT_TYPE,isFraud);
options nomprint;

**PAYMENT_TYPE vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,PAYMENT_TYPE,isFraud);
options nomprint;

**TRANSFER_TYPE vs isFraud;
%DissGraphMakerLogOdds(Ccfd.StndWithBin,10,TRANSFER_TYPE,isFraud);
options nomprint;

**Creating training and testing dataset;
data Ccfd.finalDataset;
set  Ccfd.StndWithBin ;
rand=ranuni(123456);
     if rand <=.7 then isFraudHoldout=.;
else if rand >.7 then do;
   isFraudHoldout=isFraud;
   isFraud=.;
end;
drop rand;
run;

proc freq data=Ccfd.finalDataset;
tables isFraudHoldout;
run;

Data Ccfd.Testing;
set Ccfd.finalDataset;
if isFraudHoldout>.;
run;

proc contents data= Ccfd.Testing;
run;

**Building a stepwise Logistic model;
PROC LOGISTICS DATA=Ccfd.finalDataset DESCENDING;
Title 'Predicting Fraud using Logistics regression';
MODEL isFraud = step amount oldbalanceOrg newbalanceOrig oldbalanceDest newbalanceDest isFlaggedFraud CASH_IN_TYPE CASH_OUT_TYPE DEBIT_TYPE PAYMENT_TYPE TRANSFER_TYPE /
				SELECTION = stepwise;
				output out=Ccfd.scored p=pred;
RUN;
QUIT;

proc print data=scored;
   title2 'Predicted Probabilities and 95% Confidence Limits';
run;
