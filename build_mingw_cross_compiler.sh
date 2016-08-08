#!/bin/bash
# -*- coding: utf-8 -*-
#
#  build_mingw_cross_compiler.sh
#  
#  Copyright 2016 Sean M <sean(at)ilovemycoffeecold(dot)com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  
echo "Build Cross Compiler"
echo "x86_64-w64-mingw32 (Windows 32bit & 64bit)"
echo "Getting required files:"
mkdir build_mingw_cross_compiler
cd build_mingw_cross_compiler
echo "Downloading Binutils source code"
wget http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz
echo "Downloading GCC source code"
wget http://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
echo "Downloading MinGW runtime source code"
wget -O mingw-w64-v4.0.6.tar.bz2 https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/mingw-w64-v4.0.6.tar.bz2/download

echo "Extracting Files"
tar -xvzf binutils-2.27.tar.gz
tar -xvzf gcc-5.4.0.tar.gz
tar -xvjf mingw-w64-v4.0.6.tar.bz2

echo "Configuring a few headers"
cd mingw-w64-v4.0.6/mingw-w64-headers
./configure --prefix=/usr/x86_64-w64-mingw32/sysroot --host=x86_64-w64-mingw32
echo "Build headers"
sudo make 
echo "Install headers"
sudo make install
sudo ln -s /usr/x86_64-w64-mingw32 /usr/x86_64-w64-mingw32/sysroot/mingw
sudo ln -s /usr/x86_64-w64-mingw32/sysroot/include /usr/x86_64-w64-mingw32/include
sudo install -d -m755 /usr/x86_64-w64-mingw32/sysroot/mingw/lib

echo "Locating binutils source"
cd ../../binutils-2.27
echo "Binutils source fouund"
mkdir build
cd build
echo "Configuring Binutils"
../configure --prefix=/usr --target=x86_64-w64-mingw32 --with-sysroot=/usr/x86_64-w64-mingw32/sysroot --enable-targets=x86_64-w64-mingw32,i686-w64-mingw32
sudo make
echo "Install Binutils"
sudo make install

echo "Locating GCC source"
cd ../../gcc-5.4.0
echo "Downloading prerequisites"
contrib/download_prerequisites
mkdir build_pass_one
cd build_pass_one
../configure --prefix=/usr --target=x86_64-w64-mingw32 --enable-languages=c,c++ --libexecdir=/usr/lib --disable-static --enable-threads=win32 --with-sysroot=/usr/x86_64-w64-mingw32/sysroot --enable-targets=all --with-cpu=generic
echo "Make minimum GCC"
sudo make all-gcc
echo "Install minimum GCC"
sudo make install-gcc

cd ../../mingw-w64-v4.0.6/mingw-w64-crt
./configure --prefix=/usr/x86_64-w64-mingw32/sysroot --host=x86_64-w64-mingw32
echo "Make full MinGW runtime"
sudo make
echo "Install full MinGW runtime"
sudo make install

sudo ln -s /usr/x86_64-w64-mingw32/sysroot/lib32 /usr/x86_64-w64-mingw32/lib32
sudo cp -rs /usr/x86_64-w64-mingw32/sysroot/lib /usr/x86_64-w64-mingw32/

cd ../../gcc-5.4.0
echo "Final GCC pass"
mkdir build_pass_two
cd build_pass_two
../configure --prefix=/usr --target=x86_64-w64-mingw32 --enable-languages=c,c++ --libexecdir=/usr/lib --disable-static --enable-threads=win32 --with-sysroot=/usr/x86_64-w64-mingw32/sysroot --enable-targets=all --with-cpu=generic
echo "Make final GCC"
sudo make
echo "Install final GCC"
sudo make install
echo "Done!"
echo "Special thanks to Nathan Coulson for cross compiler building notes :)"