set "SRC=src"
set "BUILD=build"
set "EXE=mygame.exe"

odin build %SRC% -out:%BUILD%\%EXE%

if errorlevel 1 (
    echo *** Build failed ***
    pause
    exit /b 1
)

pushd "%BUILD%"
"%EXE%"
popd
