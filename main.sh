#!/bin/bash

# set -x
set -e

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
if command -v pip3 &>/dev/null; then
    echo Found pip3 in system path
elif command -v apt &>/dev/null; then
    # Debian/Ubuntu
    echo Installing pip3 via apt
    sudo apt update
    sudo apt install python3-pip python3-setuptools
elif command -v zypper &>/dev/null; then
    # openSUSE
    echo Installing pip3 via zypper
    sudo zypper update
    sudo zypper install python3-pip python3-setuptools
elif command -v yum &>/dev/null; then
    # RHEL, CentOS
    echo Installing pip3 via yum
    sudo yum update
    sudo yum install python-pip python-setuptools
elif command -v pacman &>/dev/null; then
    # ArchLinux
    echo Installing pip3 via pacman
    sudo pacman -Syy
    sudo pacman -S python-pip python-setuptools
elif command -v brew &>/dev/null; then
    # macOS
    echo Installing pip3 via homebrew
    brew update
    brew install python
fi
if ! command -v pip3 &>/dev/null; then
    echo Pip is not successfully installed
    exit 1
else
    echo Pip is successfully installed
fi
echo Installing sphinx via pip
pip3 install -U sphinx
echo Adding user bin to system path
PATH=$HOME/.local/bin:$PATH
if ! command -v sphinx-build &>/dev/null; then
    echo Sphinx is not successfully installed
    exit 1
else
    echo Everything goes well
fi
echo ::endgroup::

if [ "$INPUT_INSTALL_REQUIREMENTS" = "true" ] ; then
    echo ::group:: Installing requirements
    if [ -f "$doc_dir/requirements.txt" ]; then
        echo Installing python requirements
        pip3 install -r $doc_dir/requirements.txt
    else
        echo No requirements.txt found, skipped
    fi
    echo ::endgroup::
fi

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
git stash
echo Setting up branch $INPUT_TARGET_BRANCH
branch_exist=$(git ls-remote --heads origin refs/heads/$INPUT_TARGET_BRANCH)
if [ -z "$branch_exist" ]; then
    echo Branch doesn\'t exist, create an emptry branch
    git checkout --force --orphan $INPUT_TARGET_BRANCH
else
    echo Branch exists, chekcout to it
    git checkout --force $INPUT_TARGET_BRANCH
fi
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
