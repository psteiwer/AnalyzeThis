# CSVToDeepSee
Easily transform a CSV file into a personalized preview of DeepSee

Once classes are installed, a new option will be found in the System Management Portal under DeepSee -> Tools. This new option is "Import CSV Data".

Provide a CSV file and assign dimensions/measures as necessary. Once ready, click the import button. At this point, a Caché class is created based on the CSV file and the data is imported. This new class is used as the source for the DeepSee cube. A DeepSee cube is also generated based on the properties in the source class. Once the cube is created and the records are built, a sample dashboard can be viewed. A scoring system is used to evaluate and rank the possible charts and tables that are displayed on this dashboard. After getting a visual idea of what DeepSee can offer, users can begin exploring the model within Architect or the data within Analyzer.

Install Steps:
-Make CACHELIB r/w
-Download the files into a folder on your computer
-do $system.OBJ.LoadDir("<Path to the DeepSee folder from previous step>","fck",,1)
