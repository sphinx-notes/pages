======================
Sphinx to GitHub Pages
======================

.. image:: https://img.shields.io/github/stars/sphinx-notes/pages.svg?style=social&label=Star&maxAge=2592000
   :target: https://github.com/sphinx-notes/pages

The project is originated from `seanzhengw/sphinx-pages`_,
it builds Sphinx documentation and push to branch specified branch.

.. _seanzhengw/sphinx-pages: https://github.com/seanzhengw/sphinx-pages.

.. contents::
   :local:
   :backlinks: none

Different from The Predecessor
==============================

This proejct supports customize source directory of Sphinx documentation.
I file a `pull request`_ to upstream but it is not get merged yet.

This proejct supports install python packages from ``requirements.txt``
under source directory of Sphinx documentation. It is useful for such documentation
that using non builtin Sphinx extension. This feature is also contained in the
`pull request`_ I mentioned.

Finally, the most important one, The Sphinx program in `seanzhengw/sphinx-pages`_
comes from docker image that provided by Sphinx Team. It is out-of-box,
but not flexible enough.

For example, The user of `sphinx-notes/lilypond`_ should have LilyPond installed
when runing ``sphinx-builder``, there is no a esay way to ask `seanzhengw/sphinx-pages`_
install a LilyPond in docker container. The Sphinx program in this proejct comes
from the image the specified by github workflow, so you can simplily install
LilyPond before using this.

.. _pull request: https://github.com/seanzhengw/sphinx-pages/pull/1
.. _sphinx-notes/lilypond: https://github.com/sphinx-notes/lilypond

Usage
=====

Example Workflow file
---------------------

.. literalinclude:: ../.github/workflows/pages.yml
    :language: yaml

Inputs
------

.. literalinclude:: ../action.yml
    :language: yaml
