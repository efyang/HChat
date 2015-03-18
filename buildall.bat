cd %~dp0
:CheckOS
IF EXIST "%PROGRAMFILES(X86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)

:64BIT
set distver="Windowsx86_64"
GOTO END

:32BIT
set distver="Windowsx86"
GOTO END

:END
md dist
rd /s /q dist/%DISTVER%
ghc --make %~dp0src/client.hs -O2 -H500m -o ./dist/%DISTVER%/client
ghc --make %~dp0src/server.hs -O2 -H500m -o ./dist/%DISTVER%/server