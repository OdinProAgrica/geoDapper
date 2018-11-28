# geodapper
Polygon handling tools for ECL!

This project is still under development. It implements Python's Shapely functions to handle working with WKT polygons. 

Contributions welcome. 

![](https://github.com/OdinProAgrica/DocumentationImages/blob/master/geodapperLogo.png)

# Installation
There is a shell script (installPython.sh) which works fine on an Ubuntu Xenial 64-bit docker container. It will do *some* of the setup for you but it will need to be adapted to your system. You can also check out the Dockerfile we use for dev and testing which goes through all the required steps. 

Here's a few pointers:  

* Updates linux package lists
* installs the right python version (3, of course), pip and libpython3.5
* pip installs pyproj and shapely which are needed by geodapper
* Grabs the python3 plugin for HPCC 6.4.24-1 on Ubuntu Xenial 64-bit. This isn't insalled by default unless you have the with plugins version of HPCC. You can check for it (in this version at least) by seeing if \opt\HPCCSystems\versioned\python3\libpy3embed.so exists. If you have a different HPCC (or flavour of linux) then check the HPCC dowloads for the right plugin. 
* Grabs the polygonTools.py file from this repo and deploys it to /opt/HPCCSystems/scripts/polygonTools.py you may change this but you'll also need to update the SHARED module_location definition in polygonTools.ecl to reflect this. 

## Final Installation step - Manual Work required!
I could automate this but chose not to as I don't want to be responsible for nerfing your HPCC installation. The HPCC config file: 
**/etc/HPCCSystems/environment.conf**
by default contains a line: 
**additionalPlugins=python2**
This should be canged to
**additionalPlugins=python3**
then restart HPCC:
**/etc/init.d/hpcc-init restart**

Once this is done, everything should work. Just add the PolygonTools.ecl file to your ECL repo and you're good to go. 

## Common errors
If you get something along the lines of "cannot find library -lpy3plugin" then either the plugin or the config file is broken.

# How this works
So there are two kinds of functions in geodapper.polygontools:

## By-value calculations
These are singular statements such as wkt_isvalid(), poly_isin(), poly_union(). These take single values and return single values, making them useful in transforms or join conditions (although but as much logic as possible *before* the join condition to make it lighter weight!). 

## Dataset calculations
These are plural statements such as wkts_arevalid(), polys_arein(), polys_union(). These take whole datasets, the input and output record definitions are given in the ECL script (and the python script if you want to check there). In all cases they take and return a UID column so results can be joined back into a master dataset.

## Beware the Gruffalo

### Dodgy polygons
Python in HPCC is not the most stable, especially when it comes to handling exceptions. As such before *any* other operation you must check that your polygons are valid. Invalid polygons can result in (at best) missing lines in the output data and (at worst) segfaults which are near impossible to diagnose (it's usually some sort of data type issue). 

### OUTPUT() statements
Oddly, if you output your Dataset in any way before running dataset functions on it, you can cause an object not found exception to be raised by python. This includes OUTPUT, writing to a THOR file and even, for a strange reason, using PERSIST. 

If you get an error like this, check for output statements. 
