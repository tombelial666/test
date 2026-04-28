@echo off
if "%AI_TERM_PROFILE%"=="" set AI_TERM_PROFILE=cmd

set CHEAT_FILE=%APPDATA%\navi\cheats\profiles\profile-%AI_TERM_PROFILE%.cheat

if not exist "%CHEAT_FILE%" (
  echo Profile cheatsheet not found: %CHEAT_FILE%
  exit /b 1
)

navi --path "%CHEAT_FILE%" --print

