libname CCFD "C:\Users\shrey\Desktop\MY GITHUB PROJECTS\Credit_Card_Fraud";

PROC IMPORT OUT= CCFD.EDA_CCFD 
            DATAFILE= "C:\Users\shrey\Downloads\PS_20174392719_149120443
9457_log.csv\PS_20174392719_1491204439457_log.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


