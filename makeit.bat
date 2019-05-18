@echo off


  set path=..\bin;..\..\bin;c:\masm 6.14\bin
  set include=..\include;..\..\include;c:\masm 6.14\include
  set lib=..\lib;..\..\lib;c:\masm 6.14\lib
	
	ml /c /coff /Fl KaibushevaAI.asm
if errorlevel 1 goto errasm
	ml /c /coff /Fl ProcABC.asm  
if errorlevel 1 goto errasm

	link /SUBSYSTEM:CONSOLE KaibushevaAI.obj ProcABC.obj
if errorlevel 1 goto errlink

  rem %Name%.exe
  goto TheEnd

:errlink
  echo Link Error !!!!!!!!!!!!!!!!!
  goto TheEnd

:errasm
  echo Assembler Error !!!!!!!!!!!!
  goto TheEnd

:TheEnd

pause
