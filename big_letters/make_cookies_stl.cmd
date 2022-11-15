REM Google Health Research & Innovation
"%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"G\" -o cookies\big_G.stl cookies.scad
for %%x in (o g l e) do "%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"%%x\" -o cookies\%%x.stl cookies.scad

