#!/bin/bash

# set -x
# set -e

repo_dir=$GITHUB_WORKSPACE/$INPUT_REPOSITORY_PATH
doc_dir=$repo_dir/$INPUT_DOCUMENTATION_PATH

echo ::group:: Initialize various paths
echo Workspace: $GITHUB_WORKSPACE
echo Repository: $repo_dir
echo Documentation: $doc_dir
echo ::endgroup::

# The actions doesn't depends on any images,
# so we have to try various package manager.
echo ::group:: Installing Sphinx
if command -v apt &>/dev/null; then
    # Debian/Ubuntu
    sudo apt update
    sudo apt install python3-sphinx python3-pip
elif command -v zypper &>/dev/null; then
    # openSUSE
    sudo zypper update
    sudo zypper install python-Sphinx python3-pip
elif command -v yum &>/dev/null; then
    # RHEL, CentOS
    sudo yum update
    sudo yum install python-sphinx python-pip
elif command -v pacman &>/dev/null; then
    # ArchLinux
    sudo pacman -Syy
    sudo pacman -S python-sphinx python-pip
elif command -v brew &>/dev/null; then
    # macOS
    brew update
    brew install sphinx-doc
fi
echo Checking installation result
if [ ! command -v sphinx-build &>/dev/null ] \
    || [ ! command -v pip3 &>/dev/null ]; then
    echo Sphinx or pip is not successfully installed
    exit 1
else
    echo Everything goes well
fi
echo ::endgroup::

echo ::group:: Installing requirements
if [ "$INPUT_INSTALL_REQUIREMENTS" = "true" ] ; then
    pip3 install -r $doc_dir/requirements.txt
else
    echo Skipped
fi
echo ::endgroup::

echo ::group:: Creating temp directory
tmp_dir=$(mktemp -d -t pages-XXXXXXXXXX)
echo Temp directory \"$tmp_dir\" is created
echo ::endgroup::

echo ::group:: Running Sphinx builder
sphinx-build -b html $doc_dir $tmp_dir
echo ::endgroup::

echo ::group:: Setting up git repository
echo Setting up git configure
cd $repo_dir
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
echo Setting up branch $INPUT_TARGET_BRANCH
branch_exist=$(git ls-remote --heads origin refs/heads/$INPUT_TARGET_BRANCH)
if [ -z "$branch_exist" ]; then
    echo Branch doesn\'t exist, create an emptry branch
    git checkout --orphan $INPUT_TARGET_BRANCH
    git rm --cached -r .
else
    echo Branch exists, chekcout to it
    git checkout $INPUT_TARGET_BRANCH
fi
echo Cleanning up git workspace
git clean -fd
echo ::endgroup::

echo ::group:: Committing HTML documentation
cd $repo_dir
echo Deleting all file in repository
rm -vrf *
echo Copying HTML documentation to repository
cp -vr $tmp_dir/. .
echo Adding HTML documentation to repository index
git add .
echo Recording changes to repository
git commit --allow-empty -m "Add changes"
echo ::endgroup::
