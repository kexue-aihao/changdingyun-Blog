chcp 936 > nul
@echo off
cd "%~dp0"
setlocal EnableDelayedExpansion
cls
RD /S /Q txt > nul 2>&1
set updatezip=0
if exist "txt.zip" echo 是否更新本地txt.zip数据?&set /p updatezip="0不更新、1更新(默认%updatezip%):"
if %updatezip% == 1 echo 正在从 https://zip.baipiao.eu.org 下载数据文件&echo 如果长时间无法下载，请手动访问url并下载保存为 txt.zip 到本目录&curl -# https://zip.baipiao.eu.org -o txt.zip
if not exist "txt.zip" echo 正在从 https://zip.baipiao.eu.org 下载数据文件&echo 如果长时间无法下载，请手动访问url并下载保存为 txt.zip 到本目录&curl -# https://zip.baipiao.eu.org -o txt.zip
powershell Expand-Archive -Force txt.zip txt
cls
:main
set menu=2
echo 1.自治域或地区模式
echo 2.自定义端口模式
echo 0.退出
set /p menu="请选择模式(默认%menu%):"
if %menu% == 1 (
goto menu1
) else (
if %menu% == 2 (
goto menu2
) else (
exit
)
)
:menu1
echo 当前可用自治域或者地区
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr .txt') do (
for /f "tokens=1 delims=-" %%b in ('echo %%a') do (
if not defined AS%%b set AS%%b=asn&echo %%b
)
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =asn') do (
set %%i=
)
set asn=45102
set /p asn="请输入上面的自治域或者地区(默认%asn%):"
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr /I %asn%-') do (
for /f "tokens=2 delims=-" %%b in ('echo %%a') do (
if not defined TLS-%%b set TLS-%%b=asntls
)
)
set tls=1
for /f "delims=" %%a in ('set ^| findstr =asntls ^| find /c /v ""') do (
if %%a == 2 (
echo 是否启用TLS?
set /p tls="0禁用、1启用(默认%tls%):"
if !tls! == 1 (set tlsmode=true) else (set tlsmode=false)
) else (
for /f "delims=" %%b in ('set ^| findstr =asntls ^| find /c /v "0"') do (
if %%b == 1 (set tlsmode=true) else (set tlsmode=false)
)
)
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =asntls') do (
set %%i=
)
echo 当前可用端口
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr /I %asn%-%tls%-') do (
for /f "tokens=3 delims=-" %%b in ('echo %%a') do (
for /f "tokens=1 delims=." %%c in ('echo %%b') do (
echo %%c
set port=%%c
)
)
)
set /p port="请输入检测端口(默认%port%):"
goto start
:menu2
set tls=1
echo 是否启用TLS?
set /p tls="0禁用、1启用(默认%tls%):"
if !tls! == 1 (set tlsmode=true) else (set tlsmode=false)
echo 当前可用端口
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr .txt ^| findstr \-%tls%\-') do (
for /f "tokens=3 delims=-" %%b in ('echo %%a') do (
for /f "tokens=1 delims=." %%c in ('echo %%b') do (
if not defined PORT%%c set PORT%%c=asn&echo %%c&set port=%%c
)
)
)
set /p port="请输入检测端口(默认%port%):"
copy txt\*-!tls!-!port!.txt txt\ip.txt> nul 2>&1
goto start
:start
set max=100
set outfile=ip.csv
set speedtest=2
set limit=20
set test=1
if !menu! == 1 (set file=!asn!-!tls!-!port!.txt) else (set file=ip.txt)
set /p max="并发请求最大协程数(默认%max%):"
set /p outfile="输出文件名称(默认%outfile%):"
del !outfile!> nul 2>&1
set /p speedtest="下载测速协程数量,设为0禁用测速(默认%speedtest%):"
if !speedtest! == 0 (goto mode1) else (
echo 是否限制测速IP数量?
set /p test="0不限制、1限制(默认%test%):"
)
if !test! == 1 (set /p limit="按延迟排序最多测速多少个IP(默认%limit%):"
goto mode2:
) else (goto mode1)
:mode1
iptest -file=txt/!file! -port=!port! -tls=!tlsmode! -max=!max! -outfile=!outfile! -speedtest=!speedtest!
goto end
:mode2
set /a n=0
del temp> nul 2>&1
iptest -file=txt/!file! -port=!port! -tls=!tlsmode! -max=!max! -outfile=!outfile! -speedtest=0
for /f "tokens=1 delims=," %%a in ('findstr ms !outfile!') do (
echo %%a>>temp
set /a n=n+1
if !n!==!limit! goto test
)

:test
iptest -file=temp -port=!port! -tls=!tlsmode! -max=!max! -outfile=!outfile! -speedtest=!speedtest!
del temp> nul 2>&1
goto end

:end
RD /S /Q txt > nul 2>&1
powershell -Command "& {Get-Content '!outfile!' -Encoding UTF8 | Out-File '!outfile!.txt' -Encoding Default}" > nul 2>&1
move /Y !outfile!.txt !outfile! > nul 2>&1
echo 测试完毕,请按任意键关闭窗口
pause>nul