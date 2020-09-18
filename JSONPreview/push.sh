#!/bin/zsh
# Authoer: Rakuyo
# Update Date: 2020.04.07

# Starting time
start=$(date +%s)
startM=$(date +%M)

# log color configuration
Cyan='\033[0;36m'
Default='\033[0;m'

# Get path
project_path=$(cd `dirname $0` ; pwd);

cd $project_path

# Read podspec file
while read line
do

    # Get name
    if [[ $line =~ "s.name" ]] ; then
        name=`echo $line | cut -d = -f 2 | cut -d \' -f 2`
    fi

    # Get the version number
    if [[ $line =~ "s.version" ]] ; then
        version=`echo $line | cut -d = -f 2 | cut -d \' -f 2`
        break # End loop
    fi

done  < $(find ./ -name '*.podspec')

# current time
dateString=$(date "+%Y%m%d%H%M")

# info file path
if [[ -f "Other/Info.plist" ]]; then
    infoPlist=$project_path"/Other/Info.plist"
else
    infoPlist=$project_path"/"${project_path##*/}"/Other/Info.plist"
fi

# Update the info.plist file
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" $infoPlist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $dateString" $infoPlist

# add info.plist
git add $infoPlist

echo "${Default}========================================================"
echo "  The info.plist file has been updated"
echo "${Default}========================================================"

# commit information
message="[Release Script] Version updated to $version $dateString"

# Commit git
git add *.podspec && git commit -m $message && git push
git tag $version && git push origin $version

echo "${Default}========================================================"
echo "  Git push complete"
echo "${Default}========================================================"

echo "${Default}========================================================"
echo "  Start push ${Cyan}$name${Default} at $(date "+%F %r")"
echo "${Default}========================================================"

# Push
pod trunk push $name.podspec --allow-warnings --skip-tests

# Calculate the time difference
time=$(( $(date +%s) - $start ))
timeM=$(( $(date +%M) - $startM ))

echo "${Default}========================================================"
echo "  finish push ${Cyan}$name${Default}, time consuming $time second"
echo "${Default}========================================================"

say -v Mei-Jia "The push of $name is completed, it takes about $timeM minutes"
