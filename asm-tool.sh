#!/bin/bash

SUCCESS_COLOR='\033[0;32m'
EW_COLOR='\033[0;31m'
NC='\033[0m'

ERROR="${EW_COLOR}[ERROR]:${NC}"
WARNING="${EW_COLOR}[WARNING]:${NC}"

OUT_DIR="out"
BUILD_DIR="build"

function usage() {
	echo ""
	echo "*************************************"
	echo "****** Android Assembling Tool ******"
	echo "Create a signed apk file and install "
	echo "connected device. v1.0"
	echo "*************************************"
	echo ""
	echo "smali/baksmali tool added. Mode 0 represent smali/baksmali tool, mode 1 apktool."
	echo "You need to use [mode] and [build] options together."
	echo ""
	echo "Usage: asm-tool -t [asm|dasm], -a [apk file name], -m[0|1], -b[build number], -h|--help"
	exit 0
}

if [[ ! -e /usr/local/bin/apktool && ! -e /usr/bin/apktool ]]; then
	#statements
	echo -e "$ERROR Apktool is not exist!!"
	read -p  "Do you want to install Apktool?[y/N]:" choice

	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	 	#statements
	 	HOST=`uname`
	 	ARCH=`uname -m`
	 	if [[ "$HOST" == "Linux" && "$ARCH" == "x86_64" ]]; then
	 		#statements
	 		echo "Make sure you have the 32bit libraries (ia32-libs) downloaded and installed by your linux package manager, if you are on a 64bit unix system."
	 	fi
	 	wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.2.2.jar -O "$HOME/apktool_2.2.2.jar"
	 	sudo mv "$HOME/apktool_2.2.2.jar" /usr/local/bin/apktool.jar
	 	sudo wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
	 	sudo chmod +x /usr/local/bin/apktool.jar
	 	sudo chmod +x /usr/local/bin/apktool
	 else
	 	echo "Good Bye!!"
	 	exit 0
	 fi 
fi

if [[ ! -e /usr/local/bin/d2j-dex2jar.sh && ! -e /usr/bin/d2j-dex2jar.sh && 
		! -e /usr/local/bin/d2j-dex2jar && ! -e /usr/bin/d2j-dex2jar ]]; then
	#statements
	echo -e "$ERROR Dex2Jar is not exist!!"
	read -p  "Do you want to install Dex2Jar?[y/N]:" choice

	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	 	#statements
	 	wget https://bitbucket.org/pxb1988/dex2jar/downloads/dex2jar-2.0.zip -O "$HOME/dex2jar-2.0.zip"
	 	unzip "$HOME/dex2jar-2.0.zip" -d $HOME
	 	D2J_PATH="$HOME/dex2jar-2.0"
	 	if [[ ! -e /opt ]]; then
	 		#statements
	 		sudo mkdir /opt
	 	fi
	 	sudo mv $D2J_PATH /opt
	 	D2J_PATH="/opt/dex2jar-2.0"
	 	sudo chmod -R 755 "$D2J_PATH"
	 	for f in $(ls $D2J_PATH |grep .sh); do
	 		#statements
	 		echo -e "${SUCCESS_COLOR}Linking $f to /usr/local/bin/$f${NC}"
	 		sudo ln -s "$D2J_PATH/$f" /usr/local/bin/$f
	 	done
	 	rm $HOME/dex2jar-2.0.zip
	 else
	 	echo "Good Bye!!"
	 	exit 0
	 fi 
fi

if [[ $# -eq 0 ]]; then
	#statements
	usage
fi

while [[ $# > 0 ]]; do
	#statements
	key="$1"
	case $key in
		-t)
		TYPE="$2"
		if [[ -z "$TYPE" ]]; then
			#statements
			usage
		fi
		shift
		;;
		-a)
		APKNAME="$2"
		shift
		;;
		-m)
		MODE="$2"
		if [[ -z "$MODE" ]]; then
			#statements
			usage
		fi
		shift
		;;
		-b)
		BUILDNUM="$2"
		shift
		;;
		-h|--help)
		usage
		shift
		;;
		*)
		echo -e "$ERROR Invalid command."
		usage
		;;
	esac
	shift
done

if [[ "$TYPE" == "asm" ]]; then
	if [[ -z "$APPNAME" ]]; then
		#statements
		echo -e "$ERROR APPNAME variable is null!! You need to export APPNAME!!"
		exit 0
	fi

	if [[ -z "$PACKAGE_NAME" ]]; then
		#statements
		echo -e "$WARNING If you want to uninstall app automatically from device, need to set PACKAGE_NAME value!!"
	else
		echo -e "${SUCCESS_COLOR}Application is uninstalling...${NC}"
		RESULT=`adb uninstall $PACKAGE_NAME`
		if [[ "$RESULT" == "Success" ]]; then
			#statements
			echo -e "${SUCCESS_COLOR}Application uninstall Successful!!"
		else
			echo -e "$WARNING Application uninstall process Failured!!"
		fi
	fi

	echo "-------------------------------"

	UNSIGNED=$APPNAME"_"$BUILDNUM".apk"
	SIGNED=$APPNAME"_"$BUILDNUM"_signed.apk"

	SIGNED_PATH=`pwd`"/$SIGNED"

	if [[ "$MODE" == "0" ]]; then
		#statements
		echo -e "${SUCCESS_COLOR}Creating new dex file...${NC}"
		d2j-smali.sh -o "$BUILD_DIR/classes_$BUILDNUM.dex" $OUT_DIR
		cp "$BUILD_DIR/classes_$BUILDNUM.dex" "$BUILD_DIR/$APPNAME"
		mv "$BUILD_DIR/$APPNAME/classes_$BUILDNUM.dex" "$BUILD_DIR/$APPNAME/classes.dex"
		OLD_PATH=`pwd`
		cd "$BUILD_DIR/$APPNAME"
		zip -r temp.zip . -x ".*" && mv temp.zip "../$UNSIGNED"
		rm "classes.dex"
		cd $OLD_PATH
		echo -e "${SUCCESS_COLOR}Signed apk creating...${NC}"
		d2j-apk-sign.sh -f "$BUILD_DIR/$UNSIGNED" -o "$BUILD_DIR/$SIGNED"
	elif [[ "$MODE" == "1" ]]; then
		#statements
		echo -e "${SUCCESS_COLOR}Building new apk...${NC}"
		apktool b $APPNAME -o $UNSIGNED
		echo "-------------------------------"

		echo -e "${SUCCESS_COLOR}Signed apk creating...${NC}"
		d2j-apk-sign.sh -f $UNSIGNED -o $SIGNED
		rm $UNSIGNED
		echo "-------------------------------"
	else
		usage
		exit 0
	fi

	read -p "Do you want to install apk?[y/N]:" choice

	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	 	#statements
	 	echo -e "${SUCCESS_COLOR}Apk installing...${NC}"
		adb install "$BUILD_DIR/$SIGNED"
	fi

	echo "Finish!!"
	exit 0

elif [[ "$TYPE" == "dasm" ]]; then
	#statements

	if [[ -z "$APPNAME" ]]; then
		#statements
		echo -e "$ERROR APPNAME variable is null!! You need to export APPNAME!!"
		exit 0
	fi

	if [[ -z "$APKNAME" ]]; then
		#statements
		usage
		#echo -e "$ERROR APKNAME variable is null!! You need to export APKNAME!!"
		exit 0
	fi

	if [[ "$MODE" == "0" ]]; then
		#statements
		mkdir $OUT_DIR $BUILD_DIR
		cp $APKNAME "$APPNAME.zip"
		echo -e "${SUCCESS_COLOR}Apk file is extracting...${NC}"
		unzip "$APPNAME.zip" -d $APPNAME
		rm -rf "$APPNAME/META-INF"
		cp -r $APPNAME $BUILD_DIR
		rm "$BUILD_DIR/$APPNAME/classes.dex"
		echo -e "${SUCCESS_COLOR}DEX file is converting to smali format.${NC}"
		d2j-baksmali.sh -o $OUT_DIR $APPNAME/classes.dex
		echo -e "${SUCCESS_COLOR}Decompiling completed!!${NC}"
	elif [[ "$MODE" == "1" ]]; then
		#statements
		JAR_NAME="$APPNAME.jar"
		echo -e "${SUCCESS_COLOR}Apk is decompiling...${NC}"
		apktool d $APKNAME -o $APPNAME
		echo -e "${SUCCESS_COLOR}Apk to jar...${NC}"
		d2j-dex2jar.sh $APKNAME -o $JAR_NAME
		echo -e "${SUCCESS_COLOR}Jar file is verifying...${NC}"
		d2j-asm-verify.sh $JAR_NAME
	else
		usage
	fi
	exit 0

fi
