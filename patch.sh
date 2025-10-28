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

echo Dependencies...
echo ------------------------------------------------------
declare -A dependencies=([tick]=../cv-generator-fe/scripts/tick.sh)
for key in "${!dependencies[@]}"; do echo "$key: ${dependencies[$key]}"; done
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

echo Updating global tools...
echo ------------------------------------------------------
npm outdated -g
# node -v
# # npm cache clean -f
# npm install -g n
# n latest
# node -v
npm update -g
npm ls -g --depth=1
if [ $channel == 'next' ]; then
    npm update -g @angular/cli@next
else
    npm update -g @angular/cli@latest
fi
# npm update -g heroku
heroku update
npm outdated -g
echo

echo Updating python dependent tools...
echo ------------------------------------------------------
python.exe -m pip install --upgrade pip
pip3 install -U checkov
echo

# # Whether to do a major update
# 0 - Minor
# 1 - Major
updateMajor=1

apps=(cv-generator-life-adapter project-server cv-generator-life-map cv-generator-fe)
# apps=(cv-generator-life-adapter project-server)
# apps=(cv-generator-life-map)

echo Pulling...
echo ------------------------------------------------------
for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    echo -ne $'\033[0m'

    git pull
    echo
done

echo Updating packages...
echo ------------------------------------------------------
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
echo

echo Updating next version dependent packages...
echo ------------------------------------------------------
ngApps=(cv-generator-life-map cv-generator-fe)
for i in "${!ngApps[@]}"; do
    cd $cvgRoot/${ngApps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'

    # echo Updating @angular-eslint \(x5\)...
    # depsNext=(@angular-eslint/builder @angular-eslint/eslint-plugin @angular-eslint/eslint-plugin-template @angular-eslint/schematics @angular-eslint/template-parser)
    # for dep in "${!depsNext[@]}"; do
    #     npm install --save-dev ${depsNext[$dep]}@next
    # done

    echo
done

echo Restoring pinned dependencies...
echo ------------------------------------------------------
ngApps=(cv-generator-life-map cv-generator-fe)
for i in "${!ngApps[@]}"; do
    cd $cvgRoot/${ngApps[$i]}
    echo $'\033[1;30m'
    pwd
    echo -ne $'\033[0m'

    echo Pinning dependencies...
    # echo Pinning chart.js...
    # npm install --save chart.js@^3.9.1
    # echo

    # echo Pinning heroku...
    # npm install --save heroku@~7.3.0
    # echo

    # echo Pinning zone.js...
    # npm install --save zone.js@^0.13 --force
    # echo

    echo

    echo Pinning devDependencies...
    echo Pinning bootstrap...
    npm install --save bootstrap@^4.6 --force
    echo

    echo Pinning typescript...
    npm install --save-dev typescript@^5.8 --force
    echo

    # echo Pinning jasmine...
    # npm install --save-dev jasmine-core@^4.0.0
    # echo

    echo
done

# # Deprecated
# # # https://github.com/snyk/cli/tree/master/packages/snyk-protect?utm_medium=CLI&utm_source=Snyk-CLI#readme
# echo Fixing vulnerabilities...
# echo ------------------------------------------------------
# for i in "${!apps[@]}"; do
#     cd $cvgRoot/${apps[$i]}
#     echo $'\033[1;30m'
#     pwd
#     echo -ne $'\033[0m'

#     echo y | npx snyk wizard
# done
# echo

echo Pushing...
echo ------------------------------------------------------
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

minutes=40
echo Waiting $minutes minute\(s\) for changelog to be compiled on the server...
echo ------------------------------------------------------
tick=${dependencies["tick"]}
if [[ -f $tick ]]; then
    echo Executing $tick...
    . ${dependencies["tick"]} $minutes
else
    echo $tick not found. Sleeping $minutes minute\(s\)...
    sleep $(($minutes * 60))
fi

echo Pulling changelog...
echo ------------------------------------------------------
for i in "${!apps[@]}"; do
    cd $cvgRoot/${apps[$i]}
    echo $'\033[1;30m'
    echo -ne $'\033[0m'

    git pull
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
