1) Data Exploration :
Link to Dataset: https://ourworldindata.org/covid-deaths

STEP 1) 
The dataset is imported as 2 xls files into sql server management studio
Performed basic sql queries to get some understanding on the dataset
Used CTE, TempTable for calculation & Anlysis purposes
Created a view for visualisation purpose in Tableau

STEP 2)
Imported data from SQL server to Microsoft Power BI
Transformed Data and Loaded Data for Visualisation

2) Data Cleaning with SQL :
   Project Dataset describes the housing data from Nashville
Step1)
   Imported data to SQL server Management Studio
Step 2)
   Standardised Date Format,
   Removed Unnecessary columns
   Split the Address columns into Address, City, State to improve Readability
   Populated Property Address data based on the condition
   --Having same parcelID but different uniqueID
