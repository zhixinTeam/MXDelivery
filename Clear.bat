@echo off

cd .\Source
del /s /a *.~*;*.dcu;*.stat;*.ddp

cd ..\Temp
del /s /a *.~*;*.dcu;*.ddp

cd ..\Bin
del /s /a *.~*;*.dcu;*.ddp

cd ..\DCU
del /s /a *.~*;*.dcu;*.ddp