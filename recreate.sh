#!/bin/bash
set -ex
rm -rf test
mkdir test
cd test


## Setup initial branch with some files
git init
cat > numbers.txt <<EOF
1
2
3
4
5
EOF
cat > letters.txt <<EOF
a
b
c
d
e
EOF
git add .
git commit -am 'initial'

git tag initial-release
sleep 0.5


## Here's our release branch that has some changes in it
git checkout -b branch
cat > numbers.txt <<EOF
1
a
2
3
4
5
EOF
git commit -am 'branch-numbers-a'
BRANCH_COMMIT_1=`git rev-parse HEAD`
cat > letters.txt <<EOF
a
1
b
c
d
e
EOF
git commit -am 'branch-letters-1'
BRANCH_COMMIT_2=`git rev-parse HEAD`


## And we've made some changes to master in the mean time
git checkout master
cat > numbers.txt <<EOF
1
2
3
4
d
5
EOF
git commit -am 'master-numbers-d'
MASTER_COMMIT_1=`git rev-parse HEAD`
cat > letters.txt <<EOF
a
b
c
d
4
e
EOF
git commit -am 'master-letters-4'
MASTER_COMMIT_2=`git rev-parse HEAD`


## Now the interesting part -- how does git handle cherry-picking + merges?
## There are two functions here, one for each direction of cherry-picking.


## Cherry pick from master into branch
master_to_branch() {
  git checkout branch
  git cherry-pick -x $MASTER_COMMIT_1

  # second-release contains a change from master
  git tag second-release

  git checkout master
  git merge --no-ff branch -m 'merging branch into master, after having cherry picked one of the commits from master into branch'
}

## Cherry pick from branch into master
branch_to_master() {
  git checkout branch
  git tag second-release

  git checkout master
  # cherry pick in one of branch's commits
  git cherry-pick -x $BRANCH_COMMIT_1
  git merge --no-ff branch -m 'merging branch into master, after having cherry picked one of the commits from branch into master'
}

branch_to_master

# Now what does git log say?
git log