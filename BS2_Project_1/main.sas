/* Import .txt file as 'Liver' */
proc import datafile = "liver.txt"
	out = Liver
	dbms = dlm
	replace;
run;

/* Show the contents of the data before cleaning */
proc contents data = Liver;
	run;

/* _____CLEANING THE DATA_____ */
data LiverData;
	set Liver;
		where not missing(treatmnt); /* Rid any data that does not have a treatment group */
	
	/* Change 'cholest', 'platelet', and 'triglyc' from CHAR to NUM type */
	cholest2 = cholest + 0;
	platelet2 = platelet + 0;
	triglyc2 = triglyc + 0;
	
	/* Delete VAR1, an empty variable, and old CHAR variables */
	drop VAR1;
	drop cholest;
	drop platelet;
	drop triglyc;
	
run;

/* Rename variables for a cleaner look/understanding */
proc datasets;
	modify LiverData;
	
	rename age = Age;
	rename albumin = Albumin;
	rename alkphos = Alkaline_Phosphatase;
	rename ascites = Ascites_Presence;
	rename bili = Bilirubin;
	rename cholest2 = Cholesterol;
	rename edema = Edema_Presence;
	rename edmadj = Edema_Graded;
	rename hepmeg = Hepatomegaly_Presence;
	rename obstime = Observation_Time;
	rename platelet2 = Platelet_Count;
	rename protime = Prothrombin_Time;
	rename sex = Sex;
	rename sgot = SGOT;
	rename spiders = Spider_Angiomata_Presence;
	rename stage = Stage;
	rename status = Status;
	rename treatmnt = Treatment;
	rename triglyc2 = Triglycerides;
	rename urinecu = Urine_Copper;
run;

/* Show the contents of the cleaned data */
proc contents data = LiverData;
	run;

/* Print the table of the cleaned data */
proc print data = LiverData; 
	run;

/* Wilcoxon Rank Sum Test for continuous variables based on Treatment */
proc npar1way data = LiverData wilcoxon;
	class Treatment;
	var Age;
	var Albumin;
	var Alkaline_Phosphatase;
	var Bilirubin;
	var Cholesterol;
	var Observation_Time;
	var Platelet_Count;
	var Prothrombin_Time;
	var SGOT;
	var Triglycerides;
	var Urine_Copper;
run;

/* Testing Normality for all variables */
proc univariate data = LiverData normal alpha = 0.05;

	*class Treatment;
	
	var Age;
	var Albumin;
	var Alkaline_Phosphatase;
	var Bilirubin;
	var Cholesterol;
	var Observation_Time;
	var Platelet_Count;
	var Prothrombin_Time;
	var SGOT;
	var Triglycerides;
	var Urine_Copper;
	
	*histogram Age / normal;
	*histogram Albumin / normal;
	*histogram Alkaline_Phosphatase / normal;
	*histogram Bilirubin / normal;
	*histogram Cholesterol / normal;
	*histogram Observation_Time / normal;
	*histogram Platelet_Count / normal;
	*histogram Prothrombin_Time / normal;
	*histogram SGOT / normal;
	*histogram Triglycerides / normal;
	*histogram Urine_Copper / normal;

run;

/* Vertical Box Plot for Bilirubin Levels by Treatment group */
proc sgplot data = LiverData;
	title "Bilirubin Levels by Treatment Group";
	vbox Bilirubin / category = Treatment;
	yaxis label = "Bilirubin Level";
run;

/* Vertical Bar for the presence of Hepatomegaly by Treatment group */
proc sgplot data = LiverData;
	title 'Hepatomegaly Presence by Treatment Group';
	vbar Hepatomegaly_Presence / group = Treatment groupdisplay = cluster ;
	xaxis values = ("0" "1") valuesdisplay=("Not Present" "Present") label="Presence of Hepatomegaly";
run;

/* Graphics for Linear Regression with Bilirubin and Hepatomegaly_Presence */
proc reg data = LiverData;
	model Bilirubin = Treatment / clb;
run;

/* Show the mean, min, max, std dev for all continuous variables */
proc means data = LiverData;
	class Treatment; /* Comment out this line to test for all, not by Treatment group */
	var Age;
	var Albumin;
	var Alkaline_Phosphatase;
	var Bilirubin;
	var Cholesterol;
	var Observation_Time;
	var Platelet_Count;
	var Prothrombin_Time;
	var SGOT;
	var Triglycerides;
	var Urine_Copper;
run;

/* Testing for OR and 95% CI for categorical variables */
proc freq data = LiverData;
	table Sex * Treatment / or;
	table Ascites_Presence * Treatment / or;
	table Edema_Presence * Treatment / or;
	table Hepatomegaly_Presence * Treatment / or;
	table Spider_Angiomata_Presence * Treatment / or;
	table Status * Treatment / or;
run;

/* Chi-Square Tests for Categorical variables by Treatment */
proc freq data = LiverData;
	table Sex * Treatment / chisq;
	table Stage * Treatment / chisq;
	table Ascites_Presence * Treatment / chisq;
	table Edema_Presence * Treatment / chisq;
	table Edema_Graded * Treatment / chisq;
	table Hepatomegaly_Presence * Treatment / chisq;
	table Spider_Angiomata_Presence * Treatment / chisq;
	table Status * Treatment / chisq;
run;

/* Graphics for Linear Regression with Bilirubin and Hepatomegaly_Presence */
proc reg data = LiverData;
	model Bilirubin = Hepatomegaly_Presence / clb;
run;

/* LOG TIME -------- QUESTION 7*/

/* New data set containing log transformed Bilirubin data */
data LogBiliData;
	set LiverData;
	LogBili = log(Bilirubin);
run;

/* Use Wilxocon test to check p-value and normality */
proc npar1way data = LogBiliData wilcoxon;
	class Treatment;
	var LogBili;
run;

/* Descriptive statistics for LogBili | log(Bilirubin) based on Treatment */
proc means data = LogBiliData;
	class Treatment;
	var LogBili;
run;

/* Descriptive statistics for LogBili | log(Bilirubin) for all subjects */
proc means data = LogBiliData;
	var LogBili;
run;

/* Distrubution of log(Bilirubin) */
proc univariate data = LogBiliData normal;
	class Treatment;
	var LogBili;
	histogram LogBili / normal;
run;

/* Vertical Box Plot for the Logarithmic Bilirubin Levels by Treatment group */
proc sgplot data = LogBiliData;
	title "Logarithmic Bilirubin Levels by Treatment Group";
	vbox LogBili / category = Treatment;
	yaxis label="log(Bilirubin Level)";
run;

/* Graphics for Linear Regression LogBili and Hepatomegaly_Presence */
proc reg data = LogBiliData;
	model LogBili = Hepatomegaly_Presence / clb;
run;

/* Export LogBiliData to Excel as 'liver_data.xlsx' */
proc export data = LogBiliData
	outfile = "liver_data.xlsx"
	dbms = xlsx
	replace;
	sheet = "Liver Data";
run;

/* --------END MAIN-------- */


/* ------------------------------------ */


/* --------TESTING CODE BELOW-------- */

/* T-Tests for continuous variables based on Treatment group
	to inspect significant differences, if any */
proc ttest data = LiverData alpha = 0.05;
	class Treatment;
	var Age;
	var Albumin;
	var Alkaline_Phosphatase;
	var Bilirubin;
	var Cholesterol;
	var Observation_Time;
	var Platelet_Count;
	var Prothrombin_Time;
	var SGOT;
	var Triglycerides;
	var Urine_Copper;
run;
