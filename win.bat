@echo off
if not defined PIL (
    set PIL=1
    start /min %~0
    exit /b
)

mode CON: LINES=1
mode CON: COLS=20
cd win_runtime
start /I /B qmlscene.exe ../APITester.qml
exit


