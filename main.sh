#!/bin/bash

set -x

start_group(){
    echo ::group::$@
}

end_group() {
    echo ::endgroup::
}

# The actions doesn't depends on any images, so we have to try various
# package manager.
start_group Installing Sphinx
if [ -x "$(apt -v)" ]; then
    # Debian/Ubuntu
    apt update
    apt install python3-sphinx python3-pip
elif [ -x "$(zypper -v)" ]; then
    # openSUSE
    zypper update
    zypper install python-Sphinx python3-pip
elif [ -x "$(yum -v)" ]; then
    # RHEL, CentOS
    yum update
    yum install python-sphinx python-pip
elif [ -x "$(pacman -v)" ]; then
    pacman -Syy
    pacman -S python-sphinx python-pip
elif [ -x "$(brew -v)" ]; then
    brew install sphinx-doc
fi
end_group

if [ "$INPUT_INSTALL_REQUIREMENTS" = true ] ; then
    start_group Installing requirements
    pip3 install -r $docs_src/$INPUT_SOURCE_DIR/requirements.txt
    end_group
fi

start_group Creating temp directory
tmp_dir=$(mktemp -d -t pages-XXXXXXXXXX)
echo Temp directory $tmp_dir created
endgroup

start_group Running Sphinx HTML builder
sphinx-build -b html $INPUT_SOURCE_DIR $tmp_dir
end_group

start_group Setting up branch $INPUT_TARGET_BRANCH
branch_exist=$(git ls-remote --heads origin refs/heads/$INPUT_TARGET_BRANCH)
if [ -z "$branch_exist" ]; then
    echo Branch doesnt exist, create a emptry branch
    git checkout --orphan $INPUT_TARGET_BRANCH
else 
    git checkout $INPUT_TARGET_BRANCH
fi

start_group Setting up git user information
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
endgroup

start_group Committing HTML documentation
git clean -fd
cp $tmp_dir/* .
git commit -a --allow-empty -m "Add changes" 
endgroup ::endgroup::

