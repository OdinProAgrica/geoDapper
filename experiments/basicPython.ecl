IMPORT python3;

STRING  whatshere(STRING x) := EMBED(python3)

import os
outstr = ''
midstr = '\n'
for i in os.walk(x):
  outstr = outstr + str(i) + midstr
return outstr

ENDEMBED;


checkOwn(STRING filename) := EMBED(python3) 
from os import stat
from pwd import getpwuid

return getpwuid(stat(filename).st_uid).pw_name
ENDEMBED;

STRING  whereami() := IMPORT(python3, 'os.getcwd');
STRING  whatversion() := IMPORT(python3, 'platform.python_version');
makedir(STRING pth) := IMPORT(python3, 'os.mkdir');

REAL floater(INTEGER x) := IMPORT(python3, 'numpy.float');

whereami();