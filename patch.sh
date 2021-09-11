#!/bin/bash

echo $'\033[1;33m'Running script patch
echo ------------------------------------------------------$'\033[1;33m'
echo

echo $'\033[0;33m'Starting patcher...$'\033[0m'
echo
pwd=$(pwd)
pwd
ls -aF --color=always
echo

cvgRoot=$pwd/'..'

# switch channel
# channel='next'
channel='latest'
if [ $channel == 'next' ]; then
    next='--next'
else
    next=''
fi

# update global tools
npm outdated -g
# node -v
# # npm cache clean -f
# npm install -g n
# n latest
# node -v
npm update -g
if [ $channel == 'next' ]; then
    npm update -g @angular/cli@next
else
    npm update -g @angular/cli@latest
fi
# npm update -g heroku
npm outdated -g

# # Whether to do a major update
# 0 - Minor
# 1 - Major
updateMajor=1

apps=(cv-generator-life-adapter project-server cv-generator-life-map cv-generator-fe)
# apps=(cv-generator-life-adapter project-server)
# apps=(cv-generator-life-map)

for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    echo -ne $'\033[0m'

    git pull
    echo
done

for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'
    # ls -aF --color=always package.json

    # test if angular project
    [ -f "angular.json" ]
    angular=$?

    # update all
    npm outdated
    if [ $angular == 0 ]; then
        echo y | ng update $next
    fi
    if [ $updateMajor == 1 ]; then
        echo Major npx update...
        echo y | npx npm-check-updates --timeout 600000 -u --packageFile package.json
    else
        echo Minor npx update...
        echo y | npx npm-check-updates --target minor --timeout 600000 -u --packageFile package.json
    fi
    npm install --legacy-peer-deps
    if [ $angular == 0 ]; then
        echo y | ng update --allow-dirty --force $next
    fi
    npm update
    # # implicit (@prepare)
    # npx snyk protect
    npm outdated
done
for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'

    echo y | npx snyk wizard
done

ngApps=(cv-generator-life-adapter project-server)
for i in "${!ngApps[@]}"; do
    cd $cvgRoot/${ngApps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'

    echo Restore Angular pinned dependencies...
    npm install --save-dev typescript@4.3
    echo
done

# apps=(cv-generator-life-adapter project-server)

for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'

    git add .
    git commit -am 'ci(update): bump dependencies'
    git push
    echo
done

echo $'\033[1;30m'Restoring directory...$'\033[0m'
cd $pwd
pwd
ls -aF --color=always
echo

echo
echo $'\033[0;32m'Patcher finished.$'\033[0m'

echo
# read  -n 1 -p "x" input
# exit
