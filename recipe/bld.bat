
: remove sh.exe from PATH
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

mkdir build && cd build

:: Configure.
cmake -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX:\=/%/mingw-w64 ^
  -DCMAKE_C_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4" ^
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions --param=ssp-buffer-size=4" ^
  ..
if errorlevel 1 exit 1

:: Build.
mingw32-make install -j %CPU_COUNT%
if errorlevel 1 exit 1