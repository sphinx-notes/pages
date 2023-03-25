=========================
Sphinx to GitHub Pages V3
=========================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

Helps you deploy your Sphinx documentation to Github Pages.

.. warning:: v3 is **in beta and subject to change**, use v2__ if you need a stable version.

__ https://github.com/sphinx-notes/pages/tree/v2

Usage
=====

1. `Set the publishing sources to "Github Actions"`__
2. Create workflow:

   .. code-block:: yaml

      name: Deploy Sphinx documentation to Pages

      # Runs on pushes targeting the default branch
      on:
        push:
          branches: [master]

      jobs:
        pages:
          runs-on: ubuntu-20.04
          environment:
            name: github-pages
            url: ${{ steps.deployment.outputs.page_url }}
          permissions:
            pages: write
            id-token: write
          steps:
          - id: deployment
            uses: sphinx-notes/pages@v3

__ https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow

Inputs
======

========================== ============================ ======== ==============================================
Input                      Default                      Required Description
-------------------------- ---------------------------- -------- ----------------------------------------------
``documentation_path``     ``./docs``                   false    Path to Sphinx source files
``requirements_path``      ``./docs/requirements.txt``  false    Path to to requirements file,
                                                                 used in ``pip install -r XXX`` command
``pyproject_extras``       ``docs``                     false    Extras of `Requirement Specifier`__
                                                                 used in ``pip install .[XXX]``
``python_version``         ``3.10``                     false    Version of Python
``sphinx_version``         ``5.3``                      false    Version of Sphinx
``sphinx_build_options``   ````                         false    Additional options passed to ``sphinx-build``
``cache``                  ``false``                    false    Enable cache to speed up documentation building
========================== ============================ ======== ===============================================

__ https://pip.pypa.io/en/stable/reference/requirement-specifiers/#overview

Outputs
=======

======================= ============================
Output                  Description
----------------------- ----------------------------
``page_url``            URL to deployed GitHub Pages
======================= ============================

Examples
========

The following repository's pages are built by this action:

- https://github.com/SilverRainZ/bullet
- https://github.com/sphinx-notes/pages
- https://github.com/sphinx-notes/any
- https://github.com/sphinx-notes/snippet
- https://github.com/sphinx-notes/lilypond
- https://github.com/sphinx-notes/strike
- `and more...`__

You can find the workflow file in the above repositories.

__ https://github.com/sphinx-notes/pages/network/dependents

Tips
====

Copy extra files to site
************************

Use Sphinx confval html_extra_path__.

__ https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_extra_path

Cancel any in-progress job
**************************

It is useful when you have pushed a new commit to remote but the job of the previous 
commit is not finished yet. See concurrency__ for more details.

.. code-block:: yaml

   concurrency:
     group: ${{ github.ref }}
     cancel-in-progress: true

__ https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency

Install extra dependencies
**************************

For python dependencies, just add them to your ``requirements.txt`` or ``pyproject.toml`` file.

For non-python dependencies, add a step to your workflow file, and install them with the appropriate tools
(such as apt, wget, ...). See `#24`__ for example.

__ https://github.com/sphinx-notes/pages/issues/24
