#!/bin/zsh
# Authoer: Rakuyo
# Update Date: 2024.01.05

project_path=$(cd `dirname $0` ; pwd)

cd $project_path

while read line
do
    if [[ $line =~ "s.name" ]] ; then
        name=`echo $line | cut -d = -f 2 | cut -d \' -f 2`
    fi

    if [[ $line =~ "s.version" ]] ; then
        version=`echo $line | cut -d = -f 2 | cut -d \' -f 2`
        break
    fi
done < $(find ./ -name '*.podspec')

lintLib(){
    pod lib lint $name.podspec --allow-warnings --skip-tests
}

release(){
    release_branch=release/$version
    
    git checkout -b $release_branch develop
    
    git_message="[Release] version: $version"
    
    git add . && git commit -m "$git_message"
    
    git checkout master
    git merge --no-ff -m 'Merge branch '$release_branch'' $release_branch
    git push origin master
    git tag $version
    git push origin $version
    git checkout develop
    git merge --no-ff -m 'Merge tag '$version' into develop' $version
    git push origin develop
    git branch -d $release_branch
    
    pod trunk push $name.podspec --allow-warnings --skip-tests
}

echo "Whether to skip local verification? [Y/N]？"
if read -t 5 is_skip_lint; then
    case $is_skip_lint in
    (N | n)
        lintLib && release;;
    (*)
        release;;
    esac
else
    release
fi
