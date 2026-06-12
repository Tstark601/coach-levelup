@echo off
echo.
echo  LevelUp Creator — Backend Server
echo  Puerto: 5000
echo  Docs:   http://localhost:5000/docs
echo.

:: Activar entorno virtual
call venv\Scripts\activate

:: Arrancar FastAPI en puerto 5000
uvicorn app.main:app --reload --host 0.0.0.0 --port 5000

pause
