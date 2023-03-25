#!/bin/bash

# set -x
set -e

echo ::group:: Initialize various paths

repo_dir=$GITHUB_WORKSPACE/$INPUT_REPOSITORY_PATH
doc_dir=$repo_dir/$INPUT_DOCUMENTATION_PATH
# https://stackoverflow.com/a/4774063/4799273
action_dir=$GITHUB_ACTION_PATH

echo Action: $action_dir
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

echo Adding ~/.local/bin to system path
PATH=$HOME/.local/bin:$PATH
if ! command -v sphinx-build &>/dev/null; then
    echo Sphinx is not successfully installed
    exit 1
else
    echo Everything goes well
fi

echo ::endgroup::

if [ ! -z "$INPUT_REQUIREMENTS_PATH" ] ; then
    echo ::group:: Installing dependencies declared by $INPUT_REQUIREMENTS_PATH
    if [ -f "$INPUT_REQUIREMENTS_PATH" ]; then
        pip3 install -r "$INPUT_REQUIREMENTS_PATH"
    else
        echo No $INPUT_REQUIREMENTS_PATH found, skipped
    fi
    echo ::endgroup::
fi

if [ ! -z "$INPUT_PYPROJECT_EXTRAS" ] ; then
    echo ::group:: Installing dependencies declared by pyproject.toml[$INPUT_PYPROJECT_EXTRAS]
    if [ -f "pyproject.toml" ]; then
        pip3 install .[$INPUT_PYPROJECT_EXTRAS]
    else
        echo No pyproject.toml found, skipped
    fi
    echo ::endgroup::
fi

echo ::group:: Preparations for incremental build

# Sphinx HTML builder will rebuild the whole project when modification time
 # (mtime) of templates of theme newer than built result. [1]
#
# These theme templates vendored in pip packages are newly installed,
# so their mtime always newr than the built result.
# Set mtime to 1990 to make sure the project won't rebuilt.
#
# .. [1] https://github.com/sphinx-doc/sphinx/blob/5.x/sphinx/builders/html/__init__.py#L417
echo Fixing timestamp of HTML theme
site_packages_dir=$(python -c 'import site; print(site.getsitepackages()[0])')
echo Python site-packages directory: $site_packages_dir
for i in $(find $site_packages_dir -name '*.html'); do
    touch -m -t 190001010000 $i
    echo Fixing timestamp of $i
done

echo Restoring timestamp of git repository
git_restore_mtime=$action_dir/git-restore-mtime
$git_restore_mtime $repo_dir

echo ::endgroup::

echo ::group:: Creating build directory
build_dir=/tmp/sphinxnotes-pages
mkdir -p $build_dir || true
echo Temp directory \"$build_dir\" is created

echo ::group:: Running Sphinx builder
if ! sphinx-build -b html $INPUT_SPHINX_BUILD_OPTIONS "$doc_dir" "$build_dir"; then
    echo ::endgroup::
    echo ::group:: Dumping Sphinx error log
    for l in $(ls /tmp/sphinx-err*); do
        cat $l
    done
    exit 1
fi
echo ::endgroup::

echo "artifact=$build_dir" >> $GITHUB_OUTPUT
