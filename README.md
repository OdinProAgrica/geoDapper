# wally

![](https://github.com/OdinProAgrica/DocumentationImages/blob/master/geodapperLogo.png)

Polygon handling tools for ECL!

This project is still under development. It implements Python's Shapely 
functions to handle working with WKT polygons. 

Contributions welcome. 


- [Documentation](#documentation)
- [Installation](#installation)
  - [ECL Code](#ecl-code)
  - [HPCC setup](#hpcc-setup)
  - [Python Packages and Dependencies](#python-packages-and-dependencies)
- [Working Functionality](#working-functionality)
  - [By value calculations](#by-value-calculations)
- [Questionable Functionality](#questionable-functionality)
  - [Dataset calculations](#dataset-calculations)
  - [Support Operations](#support-operations)
- [Beware the Gruffalo (Common Errors)](#beware-the-gruffalo-common-errors)

## Documentation
The package's github is available at: https://github.com/OdinProAgrica/wally

This package is released under GNU GPLv3 License: https://www.gnu.org/licenses/gpl-3.0.en.html


## Installation

### ECL Code

#### Option 1: bundles

wally is available as an ECL bundle. Something that we only recently learned is that HPCC actually supports libraries in a 
similar way to Python's pip. It isn't quite as fully featured but it works well enough. The basic idea is that it will 
pull down a 'bundle' of ECL code from github and install it locally *making it available as* 
*if it was part of the core libraries*. That is, you can `IMPORT` it without having to have the scripts in your repo. 

This tool is made available with ecl.exe (and its Linux equivalent). To install the latest wally release you simply run the 
following on the command line (although I hear that the latest IDE has this baked in).

```sh
ecl bundle install -v https://github.com/OdinProAgrica/wally.git
```

There are many more bundles available, but their coverage, testing and adherence to version control varies. HPCC keep a curated 
list [here](https://github.com/hpcc-systems/ecl-bundles).

If you want a specific version use that version's branch, for details see the help in **ecl bundle install**.

#### Option 2: Manual

Copy the wally folder into an ECL repository (or add the folder to your IDE's environment), you can then import the relevant 
modules. You can get zips of each version in the releases section of the github: https://github.com/OdinProAgrica/wally/releases

### HPCC setup

#### Ensure you're on Python 3

I could automate this but chose not to as I don't want to be responsible for 
nerfing your HPCC installation. The HPCC config file: 
**/etc/HPCCSystems/environment.conf**
by default contains a line: 
**additionalPlugins=python2**
This should be canged to
**additionalPlugins=python3**
then restart HPCC:
**/etc/init.d/hpcc-init restart**

### Python Packages and Dependencies

*The following needs to be run on every node in your cluster!*

There is a shell script (installPython.sh) which works fine on an Ubuntu 
Xenial 64-bit docker container. It will do *some* of the setup for you but it 
will need to be adapted to your system. You can also check out the Dockerfile 
we use for dev and testing which goes through all the required steps. 

Here's a few pointers:  

* Updates linux package lists
* installs the right python version (3, of course), pip and libpython3.5
* pip installs pyproj and shapely which are needed by wally
* Grabs the python3 plugin for HPCC 6.4.24-1 on Ubuntu Xenial 64-bit. This 
isn't insalled by default unless you have the with plugins version of HPCC. 
You can check for it (in this version at least) by seeing if 
\opt\HPCCSystems\versioned\python3\libpy3embed.so exists. If you have a 
different HPCC (or flavour of linux) then check the HPCC dowloads for the right plugin. 
* Grabs the polygonTools.py file from this repo and deploys it to 
/opt/HPCCSystems/scripts/polygonTools.py you may change this but you'll also 
need to update the SHARED module_location definition in polygonTools.ecl to 
reflect this. 

## Working Functionality
So there are two kinds of functions in wally.polygontools. By value calculations
are used as JOIN conditions and in PROJECTS, these work great! The other form, 
operations on whole datasets using Python generators, has proved unstable. As 
such we do not recommend their use at this time. The reason for this is that 
when you apply a dataset wide function it *always* dumps to the workunit, creating
WU Too Large errors frequently. Yes, I've tried setting spill to never and adding
a PERSIST to force a disk spill. Neither work. Suggestions on a postcard.  

### By value calculations
These are singular statements such as wkt_isvalid(), poly_isin(), 
poly_union(). These take single values and return single values, making them 
useful in transforms or join conditions but also making them slower as there 
is less optimisation going on. If uisng for joins, do note that you should 
have as much logic as possible *before* the join condition to make the operation
as fast as possible! 

Example workflows for key functionality area available in the wally compass:

![](https://github.com/OdinProAgrica/DocumentationImages/blob/master/polygontools/RawCompass.PNG)

#### wkt_isvalid
Takes: STRING    
Returns: BOOLEAN  
`wkt_isvalid('POLYGON((40 40, 20 45, 45 30, 40 40))')`  

#### poly_isin
Takes: STRING inner, STRING outer  
Returns: BOOLEAN  
`poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POINT(10 20)');`  
 
#### poly_intersect
Takes: STRING poly1, STRING poly2  
Returns: BOOLEAN  
`poly_isin('POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))');`  

#### project_polygon
Takes: STRING poly, STRING to_proj, STRING from_proj='epsg:4326'  
Returns: STRING (wkt)  
`project_polygon('POLYGON((40 40, 20 45, 45 30, 40 40))', 'epsg:28351');`  

#### poly_area
Remember to project first!!!  
Takes: STRING poly_in  
Returns: REAL  
`poly_area('POLYGON((40 40, 20 45, 45 30, 40 40))')`  

#### overlap_area 
Remember to project first!!!!  
Takes: SET OF STRING polys  
Returns: REAL  
`overlap_area(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);`  

#### overlap_polygon
Takes: SET OF STRING polys  
Returns: REAL  
`overlap_polygon(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);`  

#### poly_union
Takes: SET OF STRING in_polys, REAL tol=0.000001  
Returns: STRING (wkt)  
`poly_union(['POLYGON((40 40, 20 45, 45 30, 40 40))', 'POLYGON((50 50, 10 45, 45 30, 50 50))']);`  

#### poly_corners

Takes: STRING poly_in  
Returns: SET OF REAL   
`poly_corners('POLYGON((40 40, 20 45, 45 30, 40 40))');`  

#### poly_centroid 

Takes: STRING poly_in  
Returns: STRING (wkt)  
`poly_centroid('POLYGON((40 40, 20 45, 45 30, 40 40))');`  

## Questionable Functionality

These tend to cause WU Too Large errors owing to the compiler always 
spilling to the Workunit. As such their use is not currently advised. 

### Dataset calculations

These are plural statements such as wkts_arevalid(), polys_arein(), 
polys_union(). These take whole datasets so are optimised for larger 
jobs by using Python generators. In all cases they take and 
return a UID column so results can be joined back into a master dataset.

Example workflows for key functionality are available in the wally compass: 

![](https://github.com/OdinProAgrica/DocumentationImages/blob/master/polygontools/DataSetCompass.PNG)

#### wkts_are_valid

In Record  {STRING uid; STRING polygon;};  
Out Record {STRING uid; BOOLEAN is_valid;};  
`wkts_are_valid(inDS);`  

#### polys_area

In Record  {STRING uid; STRING polygon;};  
Out Record {STRING uid; REAL area;};  
`polys_area(inDS);`  

#### polys_arein - is one point/line/polygon within a polygon?

In Record  {STRING uid; STRING polygon; STRING polygon2;};  
Out Record {STRING uid; BOOLEAN is_in;};  
`polys_arein(inDS);`  

#### polys_union

In Record {STRING uid; SET OF STRING polygons;};  
Out Record {STRING uid; STRING polygon;};  
`polys_union(inDS, tol = 0.000001);`  

#### polys_intersect

In Record {STRING uid; STRING polygon; STRING polygon2;};  
Out Record {STRING uid; BOOLEAN intersects;};  
`polys_intersect(inDS);`  

#### overlap_areas

In Record {STRING uid; SET OF STRING polygons;};  
Out Record {STRING uid; REAL overlap;};  
`overlap_areas(inDS);`  

#### overlap_polygons

In Record {STRING uid; SET OF STRING polygons;};  
Out Record {STRING uid; STRING polygon;};  
`overlap_polygons(inDS);`  

#### project_polygons

In Record {STRING uid; STRING polygon;};  
Out Record {STRING uid; STRING polygon;};  
`project_polygons(inDS, 'epsg:28351', from_proj='epsg:4326');`  

#### polys_corners

In Record {STRING uid; STRING polygon;};  
Out Record {STRING uid; REAL lon_min; REAL lat_max; REAL lon_max; REAL lat_min;};  
`polys_corners(inDS);`

#### polys_centroids 

In Record  {STRING uid; STRING polygon;};  
Out Record {STRING uid; STRING centroid;};  
`polys_centroids(inDS)`  

### Support Operations

#### Polygon Rollup

This is a helper function that will take a dataset that contains polygons as strings and group them by 
the uid column. It will then roll these up, putting all polygons that share a UID into a SET OF STRING.

Takes: DATASET inDS, ECL uidcol, ECL polycol, BOOLEAN SortAndDist=TRUE  
Returns: DATASET  
`polyRollup(inDS, uidcol, polycol, SortAndDist=TRUE)`    

## Beware the Gruffalo (Common Errors)

### Python Problems

If you get something along the lines of "cannot find library -lpy3embed" then 
either the plugin or the config file is broken.

If you get any error prefixed with pyembed then the errors in the Python, not the ECL
(although that may be because you are passing dodgy data!).

### Dodgy polygons

Python in HPCC is not the most stable, especially when it comes to handling 
exceptions. As such before *any* other operation you must check that your 
polygons are valid. Invalid polygons can result in (at best) missing lines in 
the output data and (at worst) segfaults which are near impossible to 
diagnose (it's usually some sort of data type issue). 

### OUTPUT() statements

Oddly, if you output your Dataset in any way before running dataset functions 
on it, you can cause an object not found exception to be raised by python. 
This includes OUTPUT, writing to a THOR file and even, for a strange reason, 
using PERSIST.

If you get an error like this, check for output statements.
