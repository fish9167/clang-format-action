#!/bin/sh -l
set -e

# Go to the main directory
cd $GITHUB_WORKSPACE

# Find the C/C++ source files
#SRC=$(git ls-tree --full-tree -r HEAD | grep -e "\.\(c\|h\|hpp\|cpp\|cxx\)\$" | cut -f 2 | grep -v  cocos/bindings/auto)
if test -s exclude.txt ;then
  for finename in `cat exclude.txt`; do
    echo "exclude file: $finename "
    if  test -z  ${exclude};then
      exclude=${finename}
    else
      exclude="${exclude}|${finename}"
    fi
  done
  SRC=$(git ls-tree --full-tree -r HEAD | grep -e "\.\(c\|h\|hpp\|cpp\|cxx\)\$" | cut -f 2 | grep -v ${exclude})
else
  SRC=$(git ls-tree --full-tree -r HEAD | grep -e "\.\(c\|h\|hpp\|cpp\|cxx\)\$" | cut -f 2 | grep -v  cocos/bindings/auto)
fi

# Run clang-format over all the matching files
echo "Using style $1"


clang-format -style=$1 -i $SRC
# Check to see if there is anything to be done
# If so commit and push. Otherwise do nothing

 
if ! git diff --quiet; then
  MSG="Changes are applied, committed, and pushed!"
  echo "--------------------------------"
  echo "Illegal files:"
  echo "--------------------------------"
  git status | grep modified >> change.list
  sed -i 's/modified://g' change.list
  cat change.list
  rm -f change.list
else
  MSG="There are no changes, all good!"
fi
echo "::set-output name=message::$MSG"
exit 0
