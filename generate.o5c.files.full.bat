@rem merge.osc.files.bat parameters:
@rem                         source folder   target folder   frequency 

@call generate.o5c.files.bat osc_2012        o5c_2012_day    day
@call generate.o5c.files.bat o5c_2012_day    o5c_2012_10days 10days
@call generate.o5c.files.bat o5c_2012_10days o5c_2012_month  month
@call generate.o5c.files.bat o5c_2012_month  o5c_2012_year   year

@call generate.o5c.files.bat osc             o5c_day         day
@call generate.o5c.files.bat o5c_day         o5c_10days      10days
@call generate.o5c.files.bat o5c_10days      o5c_month       month
@call generate.o5c.files.bat o5c_month       o5c_year        year