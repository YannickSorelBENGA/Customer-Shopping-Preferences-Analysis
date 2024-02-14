********************* DATA SCIENCE PROJECT USING SAS *********************************************;

                ******* BUSINESS PROBLEM *******;

/*  How can we optimized inventory levels to meet the demands of the most loyal and frequently 
    purchasing customers while ensuring we have sufficient stock for other customer segments? */


*--------------------------------------------
1-	EXPLORATION AND DESCRIPTION OF DATASET
---------------------------------------------
Data Exploration involves examining the dataset to gain an initial understanding of its structure, 
                 variables, and potential insights, making it easier to use the data later.

Data description involves providing a comprehensive narrative about the dataset, its attributes,
                 and potential insights that can be derived from it. 

Our dataset named is Customer Shopping Preferences.

********************
Access dataset
********************	
	•	Creating a library;

Libname Group1 "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project";

/* /* IMPORTING DATASET Using PROC IMPORT to import the CSV file */

title "Customer Shopping Preferences";
proc import datafile= "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\Customer Shopping Preferences.csv"
            out= Group1.project /* Specify the output dataset name */
            dbms=csv /* Specify the DBMS (CSV in this case) */
            replace; /* Replace the dataset if it already exists */
     getnames=yes; /* Use the first row of the CSV file as variable names */
run;
title;

proc print data=Group1.project;
run;

/*Print the head of the data*/
ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\head.xlsx" ;
title "Customer Shopping Preferences - Head";
proc print data=Group1.project (obs=10);
run;
title;
ods excel close;

/*Print thhe tail of the data*/

ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\tail.xlsx" ;
title "Customer Shopping Preferences - Tail";
proc print data=Group1.project (firstobs=3894);
run;
title;
ods excel close;

*********************** EXPLORATORY DATA ANALYSIS (EDA) ****************************;

Proc contents data = Group1.project;run;

/* Our data have 3 903 observations and 19 variables */


/* Categorical variables

- Category
- Color
- Discount_Applied
- Gender
- Item_Purchased
- Location
- Payment_Method
- Preferred_Payment_Method
- Promo_Code_Used
- Season
- Shipping_Type
- Size
- Subscription_Status

TARGET: Frequency_of_Purchases
*/


/* Numerical variables

- Age
- Customer_ID
- Previous_Purchases
- Purchase_Amount__USD_
- Review_Rating
*/

* •	Checking the number of unique Row in each feature; 

title " Number of unique Levels in each feature";
proc freq data = Group1.project nlevels;
ods exclude onewayfreqs;
run;
title;

/* We have some categorical variables that have more that 8 levels

 - Item_Purchased
 - Location
 - Color
*/


*•	Checking the duplicated value;

Title "Duplicated values";
proc sort data = Group1.project out = Group1.project nodupkey dupout = Group1.project_dups;
by _ALL_;
run;
title;

/* Duplicated value*/
ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\dups.xlsx" ;
proc print data = Group1.project_dups;
run;
ods excel close;

 *** 3 observations with duplicate key values were deleted *** ;

******************** MISSING VALUE IDENTIFICATION ***********************;

Title "Number of missing values numerical variables";
proc means data = Group1.project nmiss;
run;
TITLE;

ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\missing.xlsx" ;
Title "Number of missing values_categorical variables";
proc sql;
select  nmiss(Category) as Category, 
		nmiss(Color) as Color, 
		nmiss(Discount_Applied) as Discount_Applied, 
		nmiss(Frequency_of_Purchases) as Frequency_of_Purchases,
		nmiss(Gender) as Gender,
		nmiss(Item_Purchased) as Item_Purchased,
		nmiss(Location) as Location,
		nmiss(Payment_Method) as Payment_Method,
		nmiss(Preferred_Payment_Method) as Preferred_Payment_Method,
		nmiss(Promo_Code_Used) as Promo_Code_Used,
		nmiss(Season) as Season,
		nmiss(Shipping_Type) as Shipping_Type,
		nmiss(Size) as Size,
		nmiss(Subscription_Status) as Subscription_Status
from Group1.project;
quit;
TITLE;
ods excel close;
/* We have missing value in these features:

For numerical feature

- Age (48 missing values)
 - Purchase_Amount__USD_ (38 missing values)
 - 48 missing values (23 missing values)

For Categorical features

- Category (4 missing values)
- Color (21 missing values)
- Gender (18 missing values)
- Location (18 missing values)
- Payment_Method (2 missing values)
- Season (1 missing values)
- Shipping_Type (17 missing values)
- Subscription_Status (2 missing values)
*/


*************** DESCRIPTIVE ANALYSIS **********************;

/* ---------------------------- Univariate Analysis ----------------------------------------------*/ 
 
/*************Features: Continuous variables*******************

Age
Previous_Purchases
Purchase_Amount__USD_
Review_Rating */

Proc means data = Group1.project n nmiss min max p1 p10 q1 median mean  std q3 p95 p99 STDERR CLM alpha=0.05 maxdec=2;
var Age Previous_Purchases Purchase_Amount__USD_ Review_Rating;
run;

 * INSIGTHS

  - We noticed the improvement of the minimum and the maximum amount of purchases between the previous and the current purchases
  - Age for 50% of customers are arround 44
  - 50% of customers received a review_rating arroung 3.7
 ;
  
* We used "normal" in proc univariate to check if the variables are normallity distributed; 

title "Analysis of numerical variable";
Proc univariate data = Group1.project normal plot;
var Age Previous_Purchases Purchase_Amount__USD_ Review_Rating;
run;
title;


/* - There is not mayor outliers and our numerical variables are normally distributed*/

/*Define a macro to plot distribution of each continuous variable*/

%macro distribution_plot(variable);
title " Distribution of &variable ";
proc sgplot data= Group1.project;
histogram &variable;
density Age /type=kernel;
run;
title; /* Resetting title to default */
%mend;

/* Variable "Age" */
%distribution_plot(Age);
/* Variable "Previous_Purchases" */
%distribution_plot(Previous_Purchases);
/* Variable "Purchase_Amount__USD_" */
%distribution_plot(Purchase_Amount__USD_);
/* Variable "Review_Rating" */
%distribution_plot(Review_Rating);

/* - People aged around 50 are the most representative of the population
   - The most representative previous purchases were made at $2, around $32, and $48.
   - The most representative current purchases have been made around $95
   - The most representative Review_rating have been made at 3.96 */


/*********************Features: Categorical variables****************

Category
Color
Discount_Applied
Frequency_of_Purchases
Gender
Item_Purchased
Location
Payment_Method
Preferred_Payment_Method
Promo_Code_Used
Season
Shipping_Type
Size
Subscription_Status */



ods graphics on;
title "Frequency of categorical variable";
proc freq data = Group1.project;
table Category Color Discount_Applied Frequency_of_Purchases Gender Item_Purchased Location Payment_Method
      Preferred_Payment_Method Promo_Code_Used Season Shipping_Type Size Subscription_Status/missing plots = freqplot(orient=horizontal scale=percent);
run;
title;
ods graphics off;


/* Visualization */

/*Define a macro to plot distribution of each categorical variable*/
%macro PieChart_plot(variable);
title " Bar chart of &variable ";
PROC GCHART DATA = Group1.project;
PIE3D &variable/ PERCENT =INSIDE;
run;
title; /* Resetting title to default */
%mend;

/* Variable "Category" */
%PieChart_plot(Category);
/* Variable "Discount_Applied" */
%PieChart_plot(Discount_Applied);
/* Variable "Frequency_of_Purchases" */
%PieChart_plot(Frequency_of_Purchases);
/* Variable "Gender" */
%PieChart_plot(Gender);
/* Variable "Payment_Method" */
%PieChart_plot(Payment_Method);
/* Variable "Preferred_Payment_Method" */
%PieChart_plot(Preferred_Payment_Method);
/* Variable "Promo_Code_Used" */
%PieChart_plot(Promo_Code_Used);
/* Variable "Season" */
%PieChart_plot(Season);
/* Variable "Shipping_Type" */
%PieChart_plot(Shipping_Type);
/* Variable "Size" */
%PieChart_plot(Size);
/* Variable "Subscription_Status" */
%PieChart_plot(Subscription_Status);


/*  INSIGHTS
   - In terms of the Category, Clothing is the best-seller with 44.56% of total Sales
   - The best-selling colors are Olive and Yellow with 4.4% each of total sales
   - 57% of purchases were not discounted
   - Sales are made at almost the same frequency. However, the frequency of purchases made every 3 months is slightly higher with 14.97%
   - Male make more purchases with a rate of 68.13% of total sales
   - The best-selling items are Blouse, Jewelry and Pants with 4.38% each of total sales
   - The Locations with the most purchases are Montana and California and where there were the worst purchases are Kansas and Rhode Island
   - The most widely used method of payment is by Credit card with 17.83%
   - 57% of purchases do not use a promotional code
   - Purchases are the same every season. However, sales in the spring season are slightly higher with 25.62% of total sales
   - Free shipping is the most used delivrery channel with 17.28%
   - Size M  are the best-selling with 45% of total sales
   - Many customers do not have subscription status (72.99%)
*/


/* ---------------------- Bivariate Analysis -------------------------------*/ 

/*********************Continuous vs Continuous****************/

* 1.Test of independence we use pearson;

title " Correlation between continuous variables ";
proc corr data=Group1.project  pearson spearman kendall;
    var Age Purchase_Amount__USD_ Review_Rating Previous_Purchases;
run;
title;

* Scatter plot for continuous vs continuous variable;
title " Scatter plot between continuous variables ";
proc sgscatter data=Group1.project; 
matrix Age Purchase_Amount__USD_ Review_Rating Previous_Purchases / diagonal=(histogram kernel);
run;
title;

/*  INSIGHTS
  - There are a negative correlation between Age, Purchase_Amount__USD_ (-0.00964), Review_Rating(-0.02478), little positive correlation between age and Previous_Purchases(0.03744). These corr are very small
  - There are little positive corr between Purchase_Amount__USD_, Review_Rating (0.02935) and Previous_Purchases (0.00696)
  - There is a litte positive correlation between Review_Rating and Previous_Purchases (0.00460)
*/

/*********************Categorical vs Categorical****************/

/*
Category
Color
Discount_Applied
Frequency_of_Purchases
Gender
Item_Purchased
Location
Payment_Method
Preferred_Payment_Method
Promo_Code_Used
Season
Shipping_Type
Size
Subscription_Status
*/

/* Bivariate analysis using PROC FREQ */

* A. The null and alternative hypothesis

 H0 : There is no statistical significant relationship between Frequency_of_purchases and others categorical variables
 HA : There is a statistical significant relationship between Frequency_of_purchases and others categorical variables;


Title "Relationship between categorical variables";
proc freq data=Group1.project;
  tables Category * Frequency_of_Purchases  / chisq norow nocol;
  tables Color * Frequency_of_Purchases  / chisq norow nocol;
  tables Discount_Applied * Frequency_of_Purchases / chisq norow nocol;
  tables Gender * Frequency_of_Purchases  / chisq norow nocol;
  tables Item_Purchased * Frequency_of_Purchases  / chisq norow nocol;
  tables Location * Frequency_of_Purchases  / chisq norow nocol;
  tables Payment_Method * Frequency_of_Purchases  / chisq norow nocol;
  tables Preferred_Payment_Method * Frequency_of_Purchases  / chisq norow nocol;
  tables Promo_Code_Used * Frequency_of_Purchases  / chisq norow nocol;
  tables Season * Frequency_of_Purchases  / chisq norow nocol;
  tables Shipping_Type * Frequency_of_Purchases  / chisq norow nocol;
  tables Size * Frequency_of_Purchases  / chisq norow nocol;
  tables Subscription_Status * Frequency_of_Purchases  / chisq norow nocol;
run;
title;

* Plotting the results using SGPLOT;
%macro scatterBar_Chart(data, var1, var2);
title "Scatter bar chart between &var1 and &var2";
proc sgplot data=&data;
Hbar &var1 /group= &var2 groupdisplay=cluster;
run;
title;
%mend;

%scatterBar_Chart(Group1.project, Category, Frequency_of_Purchases );
%scatterBar_Chart(Group1.project, Discount_Applied , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Gender , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Payment_Method , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Preferred_Payment_Method , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Promo_Code_Used , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Season , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Size , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Shipping_Type , Frequency_of_Purchases);
%scatterBar_Chart(Group1.project, Subscription_Status , Frequency_of_Purchases);

/* INSIGHTS

 - We don't have enought of evidence to says that there are no statistical significant relationship between Frequency_of_purchases
   and others categorical variable since all p-value are Greater than 5%

 - Clothing are the most with frequency of purchases made every three month and monthly
 - The highest frequency of purchases where discounts have not been applied is observed annually
 - Male Make most purchases every three months, quarterly and annually
 - Cash is the most widely used method of payment, with a high frequency of use every three months, followed by credit cards, which are used every month
 - The highest frequency of purchases where promo_code have not been used is observed annually and every three months
 - Frequency of purchases are highest in the Fall and Spring season on an annual and Bi-weekly basis
 - Frequency of purchases with size M are observed mostly annually, quarterly and weekly
 - Frequency of purchases with Free shipping are mostly observed annually and weekly 
 - The highest frequency of purchases where subscription status are not observed are made every three months, quarterly and annually.
*/

/*********************Continuous vs Categorical****************/

/* Bivariate analysis using PROC Logistic */  

* A. The null and alternative hypothesis

 H0 : There is no statistical significant relationship between Frequency_of_purchases and others variables
 HA : There is a statistical significant reationship between Frequency_of_purchases and others variables;


/* Bivariate analysis using PROC SGPLOT (Box Plot) */

%macro Bivariate_analysis_sgplot(data, var1, var2);
title "Relationship between &var1 and &var2";
proc sgplot data=&data;
  vbox &var2 / category=&var1;
  title "Box Plot: &var2 vs. &var1";
run;
%mend;

%Bivariate_analysis_sgplot(Group1.project,Frequency_of_Purchases, Age);
%Bivariate_analysis_sgplot(Group1.project,Frequency_of_Purchases, Previous_Purchases);
%Bivariate_analysis_sgplot(Group1.project,Frequency_of_Purchases, Purchase_Amount__USD_);
%Bivariate_analysis_sgplot(Group1.project,Frequency_of_Purchases, Review_Rating);

/*
 - Most purchases over $60 are made bi-weekly and quarterly
 - Review rating with 3.8 are mostly observed with the frequency of purchase every three months and monthly
 - Customers aged around 48 make the most purchases quarterly and annually.
*/

/* Find the C - statistic for the association of predicted and Observed responses based on the original data*/

ods graphics on;
title "Relationship between Frequency_of_Purchases and Numerical variables";
proc logistic data=Group1.project descending;
	class Category  Discount_Applied Gender Payment_Method
       Promo_Code_Used Season Shipping_Type Size Subscription_Status; 
	model Frequency_of_Purchases = Age Previous_Purchases Purchase_Amount__USD_ Review_Rating Category Discount_Applied Gender Payment_Method
       Promo_Code_Used Season Shipping_Type Size Subscription_Status / link = cumlogit cl lackfit details ;
run;
title;
ods graphics off;

* - The result of this analysis give us a C - statistic = 0.532  indicates a modest level of discriminative ability of the predictive model
 So that, we need to improve it by taking some actions ;


/* FEATURE ENGINEERING

 - Categorize the location in 4 Regions
 - Categorize the color in 3 primary_color
 - Categorize in 2 levels the target (Frequency_of _Purchases) in Purchases_Caterogy
 -  Categorize the shipping_type in 3 new_shipping_type
 - Used one hot encoding for Gender, promo_code_used,and Subscription_Status
 */


Data Group1.projectDef1;
	set Group1.project;

	length Region $40;
    if Location in ("Connecticut", "Maine", "Massachusetts", "New Hampshire", "Rhode Island", "Vermont", "New Jersey", "New York", "Pennsylvania") then Region = "East";    
	else if Location in ("Illinois", "Indiana", "Michigan", "Ohio", "Wisconsin", "Iowa", "Kansas", "Minnesota", "Missouri", "Nebraska", "North Dakota", "South Dakota") then Region = "Midwest";    
	else if Location in ("Delaware", "Florida", "Georgia", "Maryland", "North Carolina", "South Carolina", "Virginia", "District of Columbia", "West Virginia", "Alabama", "Kentucky", "Mississippi", "Tennessee", "Arkansas", "Louisiana", "Oklahoma", "Texas") then Region = "South";    
	else if Location in ("Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico", "Utah", "Wyoming", "Alaska", "California", "Hawaii", "Oregon", "Washington") then Region = "West";

    length Primary_Color $20;
    if Color in ("Red", "Blue", "Yellow") then Primary_Color = "Primary";    
	else if Color in ("Green", "Orange", "Purple", "Violet", "Indigo") then Primary_Color = "Secondary";    
	else if Color in ("Beige", "Black", "Brown", "Charcoal", "Cyan", "Gold", "Gray", "Lavender", "Magenta", "Maroon", "Olive", "Peach", "Pink", "Silver", "Teal", "Turquoise", "White") then Primary_Color = "Tertiary";

	length Purchase_Category $20;
	if Frequency_of_Purchases in ("Weekly", "Bi-Weekly", "Monthly") then Purchase_Category = "Regular";    
	else if Frequency_of_Purchases in ("Quarterly", "Every 3 Mon", "Annually", "Fortnightly") then Purchase_Category = "Irregular"; 

	length New_shipping_type $20;
	if Shipping_Type in("2-Day Shipping", "Free Shipping")then New_shipping_type = "Regular_shipping";
	else if Shipping_Type in("Express", "Next Day Air")then New_shipping_type = "Express_shipping";
	else if Shipping_Type in("Standard", "Store Pickup")then New_shipping_type = "Standard_shipping";

**one hot encoding to some categorical variables;

    if Gender = 'Male' then do;
        Gender_Male = 1;
        Gender_Female = 0;
    end;
    else if Gender = 'Fema' then do;
        Gender_Male = 0;
        Gender_Female = 1;
    end;

    if Promo_Code_Used = 'Yes' then do;
        With_Promo_Code = 1;
        Without_Promo_Code = 0;
    end;
    else if Promo_Code_Used = 'No' then do;
        With_Promo_Code = 0;
        Without_Promo_Code = 1;
    end; 

    if Subscription_Status = 'Yes' then  Subs = 1;
      else Subs = 0;  
Run;

proc print data = Group1.projectDef1 (obs = 5);run;


/* Find the C - statistic for the association of predicted and Observed responses based on the transform data*/

ods graphics on;
proc logistic data=Group1.projectDef1 descending ;
	class Category  Discount_Applied Gender_Male Gender_Female Payment_Method With_Promo_Code Without_Promo_Code Season Shipping_Type Size Subs 
	Age Purchase_Amount__USD_ Previous_Purchases Review_Rating Region Primary_Color; 
	model Purchase_Category = Age Previous_Purchases Purchase_Amount__USD_ Category Discount_Applied Gender_Male Gender_Female Payment_Method
       With_Promo_Code Without_Promo_Code Season Shipping_Type Size Subs  Region Primary_Color;
run;
ods graphics off;


/* INSIGHTS*/

* - The result of the categorization and one hot encoding in this analysis improve the C - statistic = 0.645.
It suggests that the model is somewhat effective at distinguishing between the observed responses based on the predicted probabilities ;

******************** MODELLING ******************;


*  use of surveyselect for sampling;

proc surveyselect data = Group1.projectDef1 rate=0.70 outall out=Group1.projectDef2 seed=1234;
run;

 * Subseting Taindata and Testdata;

data traindata testdata;
set Group1.projectDef2;
if selected=1 then output traindata;
else output testdata;
drop selected;
run;

/* Predicted Modelling */

ods graphics on; 
proc logistic data=traindata plots=ROC; 
class   Category  Discount_Applied Gender_Male Gender_Female Payment_Method With_Promo_Code Without_Promo_Code Season Shipping_Type Size Subs 
	Age Purchase_Amount__USD_ Previous_Purchases Review_Rating Region Primary_Color;
model Purchase_Category = Age Previous_Purchases Purchase_Amount__USD_ Category Discount_Applied Gender_Male Gender_Female Payment_Method
       With_Promo_Code Without_Promo_Code Season Shipping_Type Size Subs  Region Primary_Color / link = cumlogit details lackfit outroc=troc;  
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

*  Confusion matrix;
proc sort data=testpred ;
by  descending F_Purchase_Category descending  I_Purchase_Category  ;
run;

ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\confusion_matrix.xlsx" ;
proc freq data=testpred  order=data;
        table F_Purchase_Category*I_Purchase_Category / out=CellCounts;
        run;
ods excel close;

      data CellCounts;
        set CellCounts;
        Match=0;
        if F_Purchase_Category=I_Purchase_Category  then Match=1;
        run;
      proc means data=CellCounts mean;
        freq count;
        var Match;
        run;
quit;

* sensitivity;
ods excel file = "C:\Users\User\Documents\DATA SCIENCE\DATA SCIENCE PROJECT USING SAS\project\report\sensitivity.xlsx" ;
 proc freq data=testpred order=data;
        table F_Purchase_Category*I_Purchase_Category / senspec;
  run;
ods excel close;



