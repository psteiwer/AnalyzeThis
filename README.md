# AnalyzeThis
Easily transform a CSV file into a personalized preview of DeepSee

Once classes are installed, a new option will be found in the System Management Portal under DeepSee -> Tools. This new option is "Import CSV Data".

Provide a CSV file and assign dimensions/measures as necessary. Once ready, click the import button. At this point, a Caché class is created based on the CSV file and the data is imported. This new class is used as the source for the DeepSee cube. A DeepSee cube is also generated based on the properties in the source class. Once the cube is created and the records are built, a sample dashboard can be viewed. A scoring system is used to evaluate and rank the possible charts and tables that are displayed on this dashboard. After getting a visual idea of what DeepSee can offer, users can begin exploring the model within Architect or the data within Analyzer.

Install Steps:
1. Use the Download ZIP option for this project
2. Extract the files and copy path
3. (Optional) To include Management Portal UI Link 
    * Make CACHELIB r/w
4. Open terminal and ZN to desired namespace
5. Load files
    * If opted into step 3 - do $system.OBJ.LoadDir("<PATH FROM STEP 2>","ck",,1)
    * Else - do $system.OBJ.LoadDir("<PATH FROM STEP 2>/AnalyzeThis/","ck",,1)
6. Navigate to URL: <server>/<webapp>/AnalyzeThis.UI.CSVImport.cls
