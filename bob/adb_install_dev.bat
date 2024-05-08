::adb shell pm uninstall com.d954mas.game.mineuniverse.dev
adb install -r ".\releases\dev\playmarket\Punch Legend Simulator Dev\Punch Legend Simulator Dev.apk"
adb shell monkey -p com.d954mas.blocky.fighting.combat.rpg.dev -c android.intent.category.LAUNCHER 1
pause
