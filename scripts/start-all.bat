@echo off
cd /d "E:\project\resume"
echo ========================================
echo   简历系统 — 启动辅助脚本
echo ========================================
echo.

echo [1/3] 启动 Python 后端 (端口 8000)...
start /min python server\run.py
timeout /t 3 /nobreak >nul
echo   后端已启动: http://localhost:8000/api/health
echo.

echo [2/3] 设置端口转发 PC->模拟器 (localhost:8888->模拟器:8888)...
"E:\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" fport tcp:8888 tcp:8888
echo   完成

echo [3/3] 设置反向转发 模拟器->PC (127.0.0.1:8000->localhost:8000)...
"E:\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" rport tcp:8000 tcp:8000
echo   完成

echo.
echo ========================================
echo   全部就绪！
echo   模拟器内 App API: 127.0.0.1:8000
echo   PC 下载 PDF:     http://localhost:8888
echo ========================================
echo.
pause
