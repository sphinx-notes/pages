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
          runs-on: ubuntu-latest
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
          runs-on: ubuntu-latest
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
``pyproject_group``                                     false    Dependency group (PEP 735) to install,
                                                                 used in ``pip install --group XXX``
========================== ============================ ======== =================================================

Advanced
********

In most cases you don't need to know about the following inputs.
Unless you need to highly customize the action's behavior.

========================== ============================ ======== =================================================
Input                      Default                      Required Description
-------------------------- ---------------------------- -------- -------------------------------------------------
``python_version``         ``3.12``                     false    Version of Python
``installer``              ``pip``                      false    Python package installer used to install
                                                                 dependencies, ``pip`` or ``uv``
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

In your ``pyproject.toml`` file, there are two places to declare the packages needed to build your docs
(such as Sphinx themes and extensions):

``[project.optional-dependencies]``
   These are *extras* of your package, meaning they get published as part of your package's metadata
   and can be installed by your users, e.g. ``pip install yourpkg[docs]``.
   Use the ``pyproject_extras`` input (default: ``docs``) to select which extra to install, with the
   same key as used in ``[project.optional-dependencies]``:

   .. code-block:: toml

      [project.optional-dependencies]
      docs = ["sphinx", "furo"]

``[dependency-groups]``
   This is the newer `PEP 735`__ mechanism for declaring dev-only dependencies. Unlike extras, groups
   are **never** seen by the built/published package — the ideal place for docs tooling that has
   nothing to do with your library's runtime dependencies. Use the ``pyproject_group`` input (default:
   empty, i.e. disabled) to select which group to install:

   .. code-block:: toml

      [dependency-groups]
      docs = ["sphinx", "furo"]

   ``pyproject_group`` only accepts a single group name, and requires ``pip >= 25.1`` (the action
   upgrades pip automatically when this input is set). To combine several groups, compose them inside
   ``pyproject.toml`` itself using PEP 735's ``include-group``, e.g.:

   .. code-block:: toml

      [dependency-groups]
      test = ["pytest"]
      docs = ["sphinx", "furo", {include-group = "test"}]

__ https://peps.python.org/pep-0735/

For non-python dependencies, add a step to your workflow file, and install them with the appropriate tools
(such as apt, wget, ...). See `#24`__ for example.

__ https://github.com/sphinx-notes/pages/issues/24

Speed up installation with uv
*****************************

Dependencies are installed with pip by default. Set the ``installer`` input to ``uv``
to install them with uv__ instead, which is usually much faster:

.. code:: yaml

   - id: deployment
     uses: sphinx-notes/pages@v3
     with:
       installer: uv

__ https://github.com/astral-sh/uv

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
