@echo off
cd /d C:\Users\Home\git\runpod_noVenv\setup

:: Prompt for commit message
set /p commitMessage="Enter commit message: "

:: If no message is entered, use default
if "%commitMessage%"=="" set commitMessage="manual sync"

git add .
git commit -m "%commitMessage%"
git push