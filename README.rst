=========================
Sphinx to GitHub Pages V3
=========================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

Helps you deploy your Sphinx documentation to Github Pages.

Usage
=====

We provides two ways for publishing GitHub pages.
The first one is the default but **still in beta**, use the second one if you tend to be stable.

Publishing with this action (default)
***************************************

1. `Set the publishing sources to "Github Actions"`__
2. Create the following workflow:

   .. code-block:: yaml

      name: Deploy Sphinx documentation to Pages

      on:
        push:
          branches: [master] # branch to trigger deployment

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

Publishing from a branch (classical)
************************************

1. Create a branch ``gh-pages``
2. `Set the publishing sources to "Deploy from a branch"`__, then specify the branch just created
3. Create the following workflow, in this way user need to publish the site by another action,
   we use `peaceiris/actions-gh-pages`__ here:

   .. code-block:: yaml

      name: Deploy Sphinx documentation to Pages

      on:
        push:
          branches: [master] # branch to trigger deployment

      jobs:
        pages:
          runs-on: ubuntu-20.04
          steps:
          - id: deployment
            uses: sphinx-notes/pages@v3
            with:
              publish: false
          - uses: peaceiris/actions-gh-pages@v3
            with:
              github_token: ${{ secrets.GITHUB_TOKEN }}
              publish_dir: ${{ steps.deployment.outputs.artifact }}

__ https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-from-a-branch
__ https://github.com/peaceiris/actions-gh-pages

Inputs
======

========================== ============================ ======== =================================================
Input                      Default                      Required Description
-------------------------- ---------------------------- -------- -------------------------------------------------
``documentation_path``     ``./docs``                   false    Path to Sphinx source files
``requirements_path``      ``./docs/requirements.txt``  false    Path to to requirements file,
                                                                 used in ``pip install -r XXX`` command
``pyproject_extras``       ``docs``                     false    Extras of `Requirement Specifier`__
                                                                 used in ``pip install .[XXX]``
========================== ============================ ======== =================================================

Advanced
********

In most cases you don't need to know about the following inputs.
Unless you need to highly customize the action's behavior.

========================== ============================ ======== =================================================
Input                      Default                      Required Description
-------------------------- ---------------------------- -------- -------------------------------------------------
``python_version``         ``3.10``                     false    Version of Python
``sphinx_version``         ``latest``                   false    Version of Sphinx
``sphinx_build_options``                                false    Additional options passed to ``sphinx-build``
``cache``                  ``false``                    false    Enable cache to speed up documentation building
``checkout``               ``true``                     false    Whether to automatically checkout the repository,
                                                                 if false, user need to do it byself
``publish``                ``true``                     false    Whether to automatically publish the repository
========================== ============================ ======== =================================================

__ https://pip.pypa.io/en/stable/reference/requirement-specifiers/#overview

Outputs
=======

======================= =========================================================
Output                  Description
----------------------- ---------------------------------------------------------
``page_url``            URL to deployed GitHub Pages,
                        only available when option ``publish`` is set to ``true``
``artifact``            Directory where artifact (HTML documentation) is stored,
                        user can use it to deploy GitHub Pages manually
======================= =========================================================

Examples
========

The following repository's pages are built by this action:

- https://github.com/SilverRainZ/bullet
- https://github.com/sphinx-notes/pages
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

Customize checkout options
**************************

Repository is automatically checkout by default, but some user may need to customize checkout options
(For example, checkout private repository, checkout multiple repositories).
For this case, user can set the ``checkout`` options to ``false``, then use `action/checkout`__ byeself.

.. code:: yaml

   steps:
   - uses: actions/checkout@master
     with:
       YOUR_CUSTOM_OPTIONS: ...
   - id: deployment
     uses: sphinx-notes/pages@v3
     with:
       checkout: false

__ https://github.com/actions/checkout
