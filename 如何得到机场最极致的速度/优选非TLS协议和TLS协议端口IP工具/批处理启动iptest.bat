chcp 936 > nul
@echo off
cd "%~dp0"
setlocal EnableDelayedExpansion
cls
RD /S /Q txt > nul 2>&1
set updatezip=0
if exist "txt.zip" echo �Ƿ���±���txt.zip����?&set /p updatezip="0�����¡�1����(Ĭ��%updatezip%):"
if %updatezip% == 1 echo ���ڴ� https://zip.baipiao.eu.org ���������ļ�&echo �����ʱ���޷����أ����ֶ�����url�����ر���Ϊ txt.zip ����Ŀ¼&curl -# https://zip.baipiao.eu.org -o txt.zip
if not exist "txt.zip" echo ���ڴ� https://zip.baipiao.eu.org ���������ļ�&echo �����ʱ���޷����أ����ֶ�����url�����ر���Ϊ txt.zip ����Ŀ¼&curl -# https://zip.baipiao.eu.org -o txt.zip
powershell Expand-Archive -Force txt.zip txt
cls
:main
set menu=2
echo 1.����������ģʽ
echo 2.�Զ���˿�ģʽ
echo 0.�˳�
set /p menu="��ѡ��ģʽ(Ĭ��%menu%):"
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
echo ��ǰ������������ߵ���
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr .txt') do (
for /f "tokens=1 delims=-" %%b in ('echo %%a') do (
if not defined AS%%b set AS%%b=asn&echo %%b
)
)
for /f "tokens=1 delims==" %%i in ('set ^| findstr =asn') do (
set %%i=
)
set asn=45102
set /p asn="�������������������ߵ���(Ĭ��%asn%):"
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr /I %asn%-') do (
for /f "tokens=2 delims=-" %%b in ('echo %%a') do (
if not defined TLS-%%b set TLS-%%b=asntls
)
)
set tls=1
for /f "delims=" %%a in ('set ^| findstr =asntls ^| find /c /v ""') do (
if %%a == 2 (
echo �Ƿ�����TLS?
set /p tls="0���á�1����(Ĭ��%tls%):"
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
echo ��ǰ���ö˿�
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr /I %asn%-%tls%-') do (
for /f "tokens=3 delims=-" %%b in ('echo %%a') do (
for /f "tokens=1 delims=." %%c in ('echo %%b') do (
echo %%c
set port=%%c
)
)
)
set /p port="��������˿�(Ĭ��%port%):"
goto start
:menu2
set tls=1
echo �Ƿ�����TLS?
set /p tls="0���á�1����(Ĭ��%tls%):"
if !tls! == 1 (set tlsmode=true) else (set tlsmode=false)
echo ��ǰ���ö˿�
for /f "tokens=4 delims= " %%a in ('dir txt ^| findstr .txt ^| findstr \-%tls%\-') do (
for /f "tokens=3 delims=-" %%b in ('echo %%a') do (
for /f "tokens=1 delims=." %%c in ('echo %%b') do (
if not defined PORT%%c set PORT%%c=asn&echo %%c&set port=%%c
)
)
)
set /p port="��������˿�(Ĭ��%port%):"
copy txt\*-!tls!-!port!.txt txt\ip.txt> nul 2>&1
goto start
:start
set max=100
set outfile=ip.csv
set speedtest=2
set limit=20
set test=1
if !menu! == 1 (set file=!asn!-!tls!-!port!.txt) else (set file=ip.txt)
set /p max="�����������Э����(Ĭ��%max%):"
set /p outfile="����ļ�����(Ĭ��%outfile%):"
del !outfile!> nul 2>&1
set /p speedtest="���ز���Э������,��Ϊ0���ò���(Ĭ��%speedtest%):"
if !speedtest! == 0 (goto mode1) else (
echo �Ƿ����Ʋ���IP����?
set /p test="0�����ơ�1����(Ĭ��%test%):"
)
if !test! == 1 (set /p limit="���ӳ����������ٶ��ٸ�IP(Ĭ��%limit%):"
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
echo �������,�밴������رմ���
pause>nul