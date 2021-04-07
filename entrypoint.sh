#!/bin/sh -l
set -e

# Go to the main directory
cd $GITHUB_WORKSPACE

# Find the C/C++ source files
SRC=$(git ls-tree --full-tree -r HEAD | grep -e "\.\(c\|h\|hpp\|cpp\|cxx\)\$" | cut -f 2)

# Run clang-format over all the matching files
echo "Using style $1"


clang-format -style=$1 -i $SRC
# Check to see if there is anything to be done
# If so commit and push. Otherwise do nothing
echo "--------------------------------"
echo "Illegal files:"
echo "--------------------------------"
git status | grep modified >> change.list
sed -i 's/modified://g' change.list
cat change.list
 
if ! git diff --quiet; then
  # Configure the author
  echo ">> Configuring the author"
  git config --global user.email "clang-format@github-actions"
  git config --global user.name "clang-format"

  # Commit the changes
  #echo "get last_commit_msg"
  #last_commit_msg=`git show --format=%s | head -n 1`
  #echo ${last_commit_msg}
  echo ">> Committing the changes"
  git commit -a -m "Apply clang-format" || true

  # Push to the branch
  BRANCH=${GITHUB_REF#*refs/heads/}
  echo ">> Pushing to $BRANCH"
  git push -u origin $BRANCH

  # Set a message about what happened
  MSG="Changes are applied, committed, and pushed!"
  #MSG=`git diff`
  echo "::set-output name=message::$MSG"
  #exit 1
else
  MSG="There are no changes, all good!"
fi

# Push the message
echo "::set-output name=message::$MSG"
