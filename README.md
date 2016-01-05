# asm-tool
Android apk assemble and disassemble tool.

#Prerequest
	wget
	unzip

#Structure
	**APPNAME/** -> Contains unpackaged apk file.
	**out/** -> Contains .smali files converted from dex file.
	**build/** -> Contains builded and signed apk files and dex files.

#Usage
	**Important:** First you must be export APPNAME value!!
	$ export APPNAME=appname_you_want

	**Important:** If you want to auto uninstall and install apk with adb, you need to export PACKAGE_NAME value. PACKAGE_NAME must be original name of the application package.
	$ export PACKAGE_NAME=com.example

	**Disassemble:** ./asm-tool -t dasm -a com.example.apk -m[0|1]
	**Assemble:** ./asm-tool -t asm -b[build_number]

#License
	Copyright (C) 2015  Çağdaş Çağlak

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
