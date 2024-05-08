
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ./load_gdocs
node index_download_configs.js

xcopy /s /e /y .\configs ..\..\custom\configs\
pause