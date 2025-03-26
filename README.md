[logo]: https://github.com/psteiwer/AnalyzeThis/blob/master/Assets/AnalyzeThis_Cover.png "AnalyzeThis Cover Image"
## AnalyzeThis

<!--![alt text][logo]-->

After selecting a Data Source (CSV file, Caché Class, or SQL Query), your data is easily and quickly transformed into a personalized preview of DeepSee

## Accessing
Once <a href="#installation">installation</a> is complete, a new "Analyze This" Link will be added to the User Portal. The User Portal can be found from the Management Portal -> Analytics -> User Portal

## Usage
Provide a Data Source (CSV file, Caché Class, or SQL Query) and assign dimensions/measures as necessary. Once ready, click the import button. At this point, a new Caché class is created based on your Data Source and the data is imported. This new class is used as the source for the DeepSee cube. A DeepSee cube is also generated based on the properties in the source class. Once the cube is created and the records are built, a sample dashboard can be viewed. A scoring system is used to evaluate and rank the possible charts and tables that are displayed on this dashboard. After getting a visual idea of what DeepSee can offer, users can begin exploring the model within Architect or the data within Analyzer.

## Installation
1. Use the Download ZIP option for this project
2. Extract the files and copy path
   * This is the path to the directory that contains README.md and LICENSE
3. Open terminal and ZN to desired namespace
4. Run the following commands:
```
   Set path="PATH FROM STEP 2"
   Do $system.OBJ.Load(path_"/AnalyzeThis/Installer.cls","ck")
   Do ##class(AnalyzeThis.Installer).RunInstaller(path)
```
5. From the Management Portal, navigate to DeepSee/Analytics->User Portal
   * Find new "AnalyzeThis" Link with custom Cover Image
   
<!--![alt text][logo]-->
