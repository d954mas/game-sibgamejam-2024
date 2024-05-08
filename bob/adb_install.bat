::adb shell pm uninstall com.d954mas.game.mineuniverse.dev
adb install -r ".\releases\release\playmarket\Punch Legend Simulator\Punch Legend Simulator.apk"
adb shell monkey -p com.d954mas.punch.legend.simulator.idle -c android.intent.category.LAUNCHER 1
pause
