@echo off
setlocal

REM Set the user variable
set "user=u0_a315"

REM Define the file to store the list of servers
set "server_list_file=servers.csv"

REM Start by showing the main menu
goto :menu

REM Function to add a server to the list
:add_server
cls
echo Add a new server
echo -----------------
echo Enter the environment (e.g., IN, UAT):
set /p env=
if "%env%"=="" (
    echo Environment cannot be empty.
    pause
    goto :add_server
)

echo Enter the sub-environment (e.g., UAT1, UAT2):
set /p sub_env=
if "%sub_env%"=="" (
    echo Sub-environment cannot be empty.
    pause
    goto :add_server
)

echo Enter the application (e.g., WEB):
set /p app=
if "%app%"=="" (
    echo Application cannot be empty.
    pause
    goto :add_server
)

echo Enter the LM (e.g., 1):
set /p lm=
if "%lm%"=="" (
    echo LM cannot be empty.
    pause
    goto :add_server
)

echo Enter the hostname (e.g., 192.168.1.10):
set /p hostname=
if "%hostname%"=="" (
    echo Hostname cannot be empty.
    pause
    goto :add_server
)

echo %env%,%sub_env%,%app%,%lm%,%hostname% >> "%server_list_file%"
echo Server added successfully.
pause
goto :menu

REM Function to display the server list and select a server to SSH
:select_server
cls
echo Select a server to SSH
echo ----------------------
setlocal enabledelayedexpansion

REM Step 1: Select Environment
echo Step 1: Select Environment
set count=0
for /f "tokens=1 delims=," %%i in ('type "%server_list_file%" ^| sort /unique') do (
    set /a count+=1
    set "env[!count!]=%%i"
    echo !count!. %%i
)
if %count%==0 (
    echo No environments found.
    endlocal
    pause
    goto :menu
)
echo Enter the number of the environment:
set /p env_choice=
if not defined env[%env_choice%] (
    echo Invalid choice.
    endlocal
    pause
    goto :menu
)
set "selected_env=!env[%env_choice%]!"

REM Step 2: Select Sub-Environment
echo Step 2: Select Sub-Environment
set count=0
for /f "tokens=2 delims=," %%i in ('findstr /b /c:"%selected_env%," "%server_list_file%"') do (
    set /a count+=1
    set "sub_env[!count!]=%%i"
    echo !count!. %%i
)
if %count%==0 (
    echo No sub-environments found.
    endlocal
    pause
    goto :menu
)
echo Enter the number of the sub-environment:
set /p sub_env_choice=
if not defined sub_env[%sub_env_choice%] (
    echo Invalid choice.
    endlocal
    pause
    goto :menu
)
set "selected_sub_env=!sub_env[%sub_env_choice%]!"

REM Step 3: Select Application
echo Step 3: Select Application
set count=0
for /f "tokens=3 delims=," %%i in ('findstr /b /c:"%selected_env%,%selected_sub_env%," "%server_list_file%"') do (
    set /a count+=1
    set "app[!count!]=%%i"
    echo !count!. %%i
)
if %count%==0 (
    echo No applications found.
    endlocal
    pause
    goto :menu
)
echo Enter the number of the application:
set /p app_choice=
if not defined app[%app_choice%] (
    echo Invalid choice.
    endlocal
    pause
    goto :menu
)
set "selected_app=!app[%app_choice%]!"

REM Step 4: Select LM
echo Step 4: Select LM
set count=0
for /f "tokens=4 delims=," %%i in ('findstr /b /c:"%selected_env%,%selected_sub_env%,%selected_app%," "%server_list_file%"') do (
    set /a count+=1
    set "lm[!count!]=%%i"
    echo !count!. %%i
)
if %count%==0 (
    echo No LMs found.
    endlocal
    pause
    goto :menu
)
echo Enter the number of the LM:
set /p lm_choice=
if not defined lm[%lm_choice%] (
    echo Invalid choice.
    endlocal
    pause
    goto :menu
)
set "selected_lm=!lm[%lm_choice%]!"

REM Step 5: Select Hostname
echo Step 5: Select Hostname
set count=0
for /f "tokens=5 delims=," %%i in ('findstr /b /c:"%selected_env%,%selected_sub_env%,%selected_app%,%selected_lm%," "%server_list_file%"') do (
    set /a count+=1
    set "hostname[!count!]=%%i"
    echo !count!. %%i
)
if %count%==0 (
    echo No hostnames found.
    endlocal
    pause
    goto :menu
)
echo Enter the number of the hostname:
set /p hostname_choice=
if not defined hostname[%hostname_choice%] (
    echo Invalid choice.
    endlocal
    pause
    goto :menu
)
set "selected_hostname=!hostname[%hostname_choice%]!"

echo Connecting to %selected_hostname% with user %user%
REM Replace the following line with the actual SSH command, for example:
echo "ssh %user%@%selected_hostname% -p 8022"
ssh %user%@%selected_hostname% -p 8022

endlocal
pause
goto :menu

REM Main menu
:menu
cls
echo Main Menu
echo ---------
echo 1. Add a server
echo 2. Select a server to SSH
echo 3. Exit
echo Enter your choice:
set /p choice=
if "%choice%"=="1" goto :add_server
if "%choice%"=="2" goto :select_server
if "%choice%"=="3" exit /b
echo Invalid choice.
pause
goto :menu

endlocal
