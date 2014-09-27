binaries\wget.exe -nc http://odbl.poole.ch/extracts/ukraine.osh.bz2
binaries\bzip2.exe -d -k ukraine.osh.bz2

@set javac_found=0
@for %%j in (javac.exe) do @set javac_found=1

@if %javac_found% equ 1 javac OsmHistorySplitter.java
binaries\wget.exe -nc --no-check-certificate https://www.dropbox.com/s/sgj87by9rzg8cl9/OsmHistorySplitter.class?dl=1 -O OsmHistorySplitter.class
@if not exist OsmHistorySplitter.class @echo Please download OsmHistorySplitter.class from https://www.dropbox.com/s/sgj87by9rzg8cl9/OsmHistorySplitter.class?dl=0
@if not exist OsmHistorySplitter.class @goto :eof
java -Xmx1500M OsmHistorySplitter 10