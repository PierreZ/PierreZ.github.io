#!/bin/sh

set -e;

# if [[ $(git status -s) ]]
# then
#     echo "The working directory is dirty. Please commit any pending changes."
#     exit 1;
# fi

echo "Deleting old publication"
rm -rf public
git clone git@github.com:PierreZ/pierrez.github.io.git --branch master public
rm -rf public/*
hugo -t cocoa-eh
cd public 

echo "pushing..."
git add --all && git commit -m "(./publish.sh) updating master" && git push origin master && cd ..
echo "done"
