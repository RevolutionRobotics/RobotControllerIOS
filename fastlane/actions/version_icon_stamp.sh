#!/bin/bash
### The script creates an overlay image on the app icon
### http://www.merowing.info/2013/03/overlaying-application-version-on-top-of-your-icon/#.VL0mOyjKny-

usage()
{
  echo "Usage: $0 -p <path>"
  echo ""
  echo "This script stamps the application icon image based on the input paramters"
  echo " eg. ./version_icon_stamp.sh -p /Users/kovacsdavid/devel/probono-ios/ProBono/ -l MR-kovacsd"
  echo ""
  echo "OPTIONS:"
  echo "    -h    Show this message"
  echo "    -p    path to the info plist file"
  echo "    -l    label to the icon"
}


PLIST_FILE=
PLIST_FOLDER=

while getopts “hp:l:” OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    p)
      PLIST_FOLDER=$OPTARG
      ;;
    l)
      LABEL=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

echo "Icon versioning!"

#find infoplist file
if [ -z $PLIST_FOLDER ]; then
  echo "Please set the project folder"
  usage
  exit 1
fi

PLIST_FILE=$PLIST_FOLDER/Info.plist

convertPath=$(which convert)
if [[ ! -f ${convertPath} || -z ${convertPath} ]]; then
  echo "WARNING: Skipping Icon versioning, you need to install ImageMagick and ghostscript (fonts) first, you can use brew to simplify process:
  brew install imagemagick
  brew install ghostscript"
  exit 1;
fi

function processIcon() {
    export PATH=$PATH:/usr/local/bin
    echo "Processing $1 file"
    base_file=`basename $1`
    base_path=$1
    if [[ ! -f ${base_path} || -z ${base_path} ]]; then
        echo "Couldn't find icon file..."
        exit 1
    fi

    target_file=$(echo "CONVERT-${base_file}")
    target_path="/tmp/${target_file}"

    width=$(identify -format "%[w]" ${base_path})
    height=$(echo $((width / 3)))
    echo "Width: $width $height"

    convert -background '#0008' -fill white -gravity center -size ${width}x${height}\
    caption:"${LABEL}"\
    ${base_path} +swap -gravity south -composite ${target_path}

    cp -f ${target_path} ${base_path}
    if [ $? != "0" ]; then echo -e "Couldn't copy the updated Icon"; exit 1; fi;
}

for f in $PLIST_FOLDER/Images.xcassets/AppIcon.appiconset/*.png; do
	processIcon $f ; if [ $? != "0" ]; then echo -e "Process Icon failed"; exit 1; fi;done

