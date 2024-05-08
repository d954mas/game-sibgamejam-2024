if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../

java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive --with-symbols --variant debug --platform=x86_64-win32 --bo bob/releases/dev/win clean resolve build bundle 