=========================
Sphinx to GitHub Pages V2
=========================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

Help you deploying your Sphinx documentation to Github Pages.

Usage
=====

.. note::

   You should enable extension ``sphinx.ext.githubpages`` in your ``conf.py``
   first.

This action only help you build and commit Sphinx documentation to ``gh-pages``,
branch. So we need some other actions:

- ``action/setup-python`` for installing python and pip
- ``actions/checkout`` for checking out git repository
- ``ad-m/github-push-action`` for pushing site to remote

So your workflow file should be:

.. code-block:: yaml

   name: Pages
   on:
     push:
       branches:
       - master
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/setup-python@v2
       - uses: actions/checkout@master
         with:
           fetch-depth: 0 # otherwise, you will failed to push refs to dest repo
       - name: Build and Commit
         uses: sphinx-notes/pages@v2
       - name: Push changes
         uses: ad-m/github-push-action@master
         with:
           github_token: ${{ secrets.GITHUB_TOKEN }}
           branch: gh-pages

Inputs
======

======================= ============== ============ =============================
Input                   Default        Required     Description
----------------------- -------------- ------------ -----------------------------
``documentation_path``  ``'./docs'``   ``false``    Relative path under
                                                    repository to documentation
                                                    source files
``target_branch``       ``'gh-pages'`` ``false``    Git branch where assets will
                                                    be deployed
``target_dir``          ``'.'``        ``false``    Directory in Github Pages
                                                    where Sphinx Pages will be
                                                    placed
``repository_path``     ``'.'``        ``false``    Relative path under
                                                    ``$GITHUB_WORKSPACE`` to
                                                    place the repository.
                                                    You not need to set this
                                                    Input unless you checkout
                                                    the repository to a custom
                                                    path
``requirements_path``   ``''``         ``false``    Relative path under
                                                    ``$repository_path`` to pip
                                                    requirements file
``sphinx_version``      ``''``         ``false``    Custom version of Sphinx
======================= ============== ============ =============================

Examples
========

The following repository's pages are built by this action:

- https://github.com/SilverRainZ/bullet
- https://github.com/sphinx-notes/pages
- https://github.com/sphinx-notes/any
- https://github.com/sphinx-notes/snippet
- https://github.com/sphinx-notes/lilypond
- https://github.com/sphinx-notes/strike
- ...

You can found the workflow file in their repository.

Tips
====

Copy extra files to site
========================

Use Sphinx confval html_extra_path__.

__ https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_extra_path
