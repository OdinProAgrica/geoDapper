IMPORT python3;

STRING  whereami() := IMPORT(python3, 'os.getcwd');
STRING  whatversion() := IMPORT(python3, 'platform.python_version');
makedir(STRING pth) := IMPORT(python3, 'os.mkdir');

REAL floater(INTEGER x) := IMPORT(python3, 'numpy.float');

whereami();