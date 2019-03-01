## Date Building ##

This project provides a script which will package HowardHinnant's date library in a similar manner to the other `build-*` projects.  It contains as a submodule, It contains as a submodule, the [date][date-release] git project.

[date-release]: https://github.com/toonetown/date

### Requirements ###

This library is header-only and the script just copies the headers into a package.  The `tz` file is *NOT* being built currently.

     
### Build Steps ###

You can package this by using the `build.sh` script:

    ./build.sh [/path/to/date-dist] package </path/to/output/directory>

Run `./build.sh` itself to see details on its options.

You can modify the execution of the scripts by setting various environment variables.  See the script sources for lists of these variables.
