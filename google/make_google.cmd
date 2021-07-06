REM Google Health Research
"%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"G\" -o health\bigG.stl letter.scad
"%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"H\" -o health\bigH.stl letter.scad
"%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"R\" -o health\bigR.stl letter.scad
for %%x in (o g l e  a t c h  s r) do "%ProgramFiles%\OpenSCAD\openscad.exe" -Dletter=\"%%x\" -o health\%%x.stl letter.scad

