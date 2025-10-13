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

pip3 install -U sphinxnotes-incrbuild

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

echo ::group:: Running Sphinx builder
build_dir=/tmp/sphinxnotes-pages
mkdir -p $build_dir || true
echo Temp directory \"$build_dir\" is created
if [ "$INPUT_CACHE" == "true" ]; then
    sphinx_build=sphinxnotes-incrbuild
else
    sphinx_build=sphinx-build
fi
if ! $sphinx_build -b html $INPUT_SPHINX_BUILD_OPTIONS "$doc_dir" "$build_dir"; then
    for l in $(find /tmp -name 'sphinx-err*.log' 2>/dev/null); do
        # Replace "\n" to "%0A" for supporting multiline text in the error message.
        # https://github.com/actions/toolkit/issues/193#issuecomment-605394935
        traceback=$(tail -n500 $l | awk '{ printf "%s%%0A", $0 }')
        echo "::error title=Sphinx traceback::$traceback"
    done
    echo ::endgroup::
    exit 1
fi
echo ::endgroup::

echo "artifact=$build_dir" >> $GITHUB_OUTPUT
