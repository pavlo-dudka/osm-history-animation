@rem Historical data till 31 March 2012
binaries\wget.exe -q -nc http://odbl.poole.ch/extracts/ukraine.osh.bz2
binaries\bzip2.exe -d -k ukraine.osh.bz2 

@rem Historical data from 11 February 2013
binaries\wget.exe -r -nc -np -nH -nd -P osc -l 1 -A gz http://be.gis-lab.info/data/osm_dump/diff/UA 
