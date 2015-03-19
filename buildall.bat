@ECHO OFF
cd %~dp0
:CheckOS
IF EXIST "%PROGRAMFILES(X86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)

:64BIT
set distver=Windowsx86_64
GOTO END

:32BIT
set distver=Windowsx86
GOTO END

:END
@ECHO ON
rd /s /q dist\%DISTVER%
md dist\%DISTVER%
copy /b src\curl.exe dist\%DISTVER%\curl.exe /b
ghc --make src\client.hs -O2 -H500m -o dist\%DISTVER%\client.exe
ghc --make src\server.hs -O2 -H500m -o dist\%DISTVER%\server.exe
