======================
Sphinx to GitHub Pages
======================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

The project is originated from `seanzhengw/sphinx-pages`_,
it helps you building Sphinx documentation and commit specified branch.

.. _seanzhengw/sphinx-pages: https://github.com/seanzhengw/sphinx-pages.

Usage
=====

.. note::

   You should enable extension ``sphinx.ext.githubpages`` in your ``conf.py``
   first.

The simplpest Workflow file looks like that:

.. code-block:: yaml

   - name: Build and Commit
     uses: sphinx-notes/pages@master

But note that this actions only help you build and commit Sphinx documentation,
we need another two actions: one for checking out and one for push to remote,
so your workflow file should be:

.. code-block:: yaml

   name: Pages
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
       - name: Checkout
         uses: actions/checkout@master
         with:
           fetch-depth: 0 # otherwise, you will failed to push refs to dest repo
       - name: Build and Commit
         uses: sphinx-notes/pages@master
       - name: Push changes
         uses: ad-m/github-push-action@master
         with:
           github_token: ${{ secrets.GITHUB_TOKEN }}
           branch: gh-pages

Inputs
======

:target_branch:
    (default: ``'gh-pages'``) Git branch where assets will be deployed
:repository_path:
    (default: ``'.'``) Relative path under $GITHUB_WORKSPACE to place the repository
:documentation_path:
    (default: ``'.'``) Relative path under repository to documentation source files
:install_requirements:
    (default: ``'true'``) Install Sphinx extensions listed in $documentation_path/requirements.txt, symbol link is supported
:extra_files:
    (default: ``''``) Extras files(such as README, LICENSE) to be commited to $target_branch

    .. topic:: DEPREDATED

       Use html_extra_path_ instead.

       .. _html_extra_path: https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_extra_path

Examples
========

The following pages are built by this action:

- https://sphinx-notes.github.io/pages
- https://sphinx-notes.github.io/lilypond
- https://sphinx-notes.github.io/any
- https://sphinx-notes.github.io/strike
- You can visit https://sphinx-notes.github.io for more pages...

You can found the workflow file in their corrsponding repository.
