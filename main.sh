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

echo Installing sphinx via pip
if [ -z "$INPUT_SPHINX_VERSION" ] ; then
    pip3 install -U sphinx
else
    pip3 install -U sphinx==$INPUT_SPHINX_VERSION
fi

echo Adding user bin to system path
PATH=$HOME/.local/bin:$PATH
if ! command -v sphinx-build &>/dev/null; then
    echo Sphinx is not successfully installed
    exit 1
else
    echo Everything goes well
fi

echo ::endgroup::

if [ ! -z "$INPUT_REQUIREMENTS_PATH" ] ; then
    echo ::group:: Installing requirements
    if [ -f "$repo_dir/$INPUT_REQUIREMENTS_PATH" ]; then
        echo Installing python requirements
        pip3 install -r "$repo_dir/$INPUT_REQUIREMENTS_PATH"
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
    echo Branch doesn\'t exist, create an empty branch
    git checkout --force --orphan $INPUT_TARGET_BRANCH
else
    echo Branch exists, checkout to it
    git checkout --force $INPUT_TARGET_BRANCH
fi
git clean -fd
echo ::endgroup::

echo ::group:: Committing HTML documentation
cd $repo_dir
echo Deleting all file in repository
rm -vrf *
echo Copying HTML documentation to repository
# Remove unused doctree
rm -rf $tmp_dir/.doctrees
cp -vr $tmp_dir/. $INPUT_TARGET_PATH
if [ ! -f "$INPUT_TARGET_PATH/.nojekyll" ]; then
    # See also sphinxnotes/pages#7
    echo Creating .nojekyll file
    touch "$INPUT_TARGET_PATH/.nojekyll"
fi
echo Adding HTML documentation to repository index
git add $INPUT_TARGET_PATH
echo Recording changes to repository
git commit --allow-empty -m "Add changes for $GITHUB_SHA"
echo ::endgroup::
