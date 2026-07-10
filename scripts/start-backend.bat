@echo off
echo Starting Resume Backend Server...
cd /d "E:\project\resume"
start /min python server\run.py
echo Backend started on port 8000
echo Health check: http://localhost:8000/api/health
pause
