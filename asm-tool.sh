#!/bin/bash

SUCCESS_COLOR='\033[0;32m'
EW_COLOR='\033[0;31m'
NC='\033[0m'

ERROR="${EW_COLOR}[ERROR]:${NC}"
WARNING="${EW_COLOR}[WARNING]:${NC}"

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
	 	wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.0.0rc4.jar -O "$HOME/apktool_2.0.0rc4.jar"
	 	mv "$HOME/apktool_2.0.0rc4.jar" /usr/local/bin/apktool.jar
	 	wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/osx/apktool -O /usr/local/bin/apktool
	 	chmod +x /usr/local/bin/apktool.jar
	 	chmod +x /usr/local/bin/apktool
	 else
	 	echo "Good Bye!!"
	 	exit 0
	 fi 
fi

if [[ ! -e /usr/local/bin/d2j-apk-sign.sh && ! -e /usr/bin/d2j-apk-sign.sh && 
	! -e /usr/local/bin/d2j-apk-sign && ! -e /usr/bin/d2j-apk-sign ]]; then
	#statements
	echo -e "$ERROR Dex2Jar is not exist!!"
	read -p  "Do you want to install Dex2Jar?[y/N]:" choice

	if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
	 	#statements
	 	wget http://heanet.dl.sourceforge.net/project/dex2jar/dex2jar-0.0.9.15.zip -O "$HOME/dex2jar-0.0.9.15.zip"
	 	unzip "$HOME/dex2jar-0.0.9.15.zip" -d $HOME
	 	D2J_PATH="$HOME/dex2jar-0.0.9.15"
	 	if [[ ! -e /opt ]]; then
	 		#statements
	 		mkdir /opt
	 	fi
	 	sudo mv $D2J_PATH /opt
	 	D2J_PATH="/opt/dex2jar-0.0.9.15"
	 	chmod -R 755 "$D2J_PATH"
	 	for f in $(ls $D2J_PATH |grep .sh); do
	 		#statements
	 		echo -e "${SUCCESS_COLOR}Linking $f to /usr/local/bin/$f${NC}"
	 		ln -s "$D2J_PATH/$f" /usr/local/bin/$f
	 	done
	 	rm $HOME/dex2jar-0.0.9.15.zip
	 else
	 	echo "Good Bye!!"
	 	exit 0
	 fi 
fi

if [[ -z "$APPNAME" ]]; then
	#statements
	echo -e "$ERROR APPNAME variable is null!! You need to export APPNAME!!"
	exit 0
fi

function usage() {
	echo ""
	echo "*************************************"
	echo "****** Android Assembling Tool ******"
	echo "Create a signed apk file and install "
	echo "connected device. v0.1"
	echo "*************************************"
	echo ""
	echo "Usage: asm-apk -t [asm|dasm], -a [apk file name] , -h|--help"
	exit 0
}

function usage_example() {
	echo ""
	echo "*************************************"
	echo "****** Android Assembling Tool ******"
	echo "Create a signed apk file and install "
	echo "connected device. v0.1"
	echo "*************************************"
	echo ""
	echo -e "Requirement Tools:\n- Apktool\n- Dex2Jar"
	echo "Usage: asm-apk -t [asm|dasm], -a [apk file name] , -h|--help"
	echo ""
	echo -e "Example:\n\tImportant: First you must be export APPNAME value!!\n\tDisassemble: asm-tool -t dasm -a com.example.apk\n\tAssemble: asm-tool -t asm"
	exit 0
}

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
		-h|--help)
		usage_example
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

	UNSIGNED=$APPNAME".apk"
	SIGNED=$APPNAME"_signed.apk"

	SIGNED_PATH=`pwd`"/$SIGNED"

	if [[ -e "$SIGNED" ]]; then
		#statements
		echo -e "${SUCCESS_COLOR}Found a signed apk. REMOVED!!${NC}"
		rm $SIGNED
		echo "-------------------------------"
	fi

	echo -e "${SUCCESS_COLOR}Building new apk...${NC}"
	apktool b $APPNAME -o $UNSIGNED
	echo "-------------------------------"

	echo -e "${SUCCESS_COLOR}Signed apk creating...${NC}"
	d2j-apk-sign.sh -f $UNSIGNED -o $SIGNED
	rm $UNSIGNED
	echo "-------------------------------"

	echo "Press [ENTER] the install apk..."
	read
	echo -e "${SUCCESS_COLOR}Apk installing...${NC}"
	adb install $SIGNED

	echo "Finish!!"
	exit 0

elif [[ "$TYPE" == "dasm" ]]; then
	#statements
	if [[ -z "$APKNAME" ]]; then
		#statements
		usage
		echo -e "$ERROR APKNAME variable is null!! You need to export APKNAME!!"
		exit 0
	fi

	echo -e "${SUCCESS_COLOR}Apk is decompiling...${NC}"
	apktool d $APKNAME -o $APPNAME
	exit 0

fi
