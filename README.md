# AnalyzeThis
Easily transform a CSV file into a personalized preview of DeepSee

## Accessing
Once <a href="#installing">installation</a> is complete, a new "Analyze This" Link will be added to the User Portal. The User Portal can be found from the Management Portal -> Analytics -> User Portal

## Using
Provide a CSV file and assign dimensions/measures as necessary. Once ready, click the import button. At this point, a Caché class is created based on the CSV file and the data is imported. This new class is used as the source for the DeepSee cube. A DeepSee cube is also generated based on the properties in the source class. Once the cube is created and the records are built, a sample dashboard can be viewed. A scoring system is used to evaluate and rank the possible charts and tables that are displayed on this dashboard. After getting a visual idea of what DeepSee can offer, users can begin exploring the model within Architect or the data within Analyzer.

## Installing
1. Use the Download ZIP option for this project
2. Extract the files and copy path
3. Open terminal and ZN to desired namespace
4. Load files
    * do $system.OBJ.LoadDir("<PATH FROM STEP 2>","ck",,1)
5. From the Management Portal, navigate to DeepSee/Analytics->User Portal
   * Find "Analyze This" Link
