*******
Fishion
*******

``fishion`` is a `fish shell <https://fishshell.com>`_ function to provide
the concept of sessions. Sessions isolate command history and allow minor
customization. This helps to stay focused on the context of the session.

Usage
=====

.. code-block:: fish

    ~> fishion work  # switch to work session
    ~> ...
    ~> fishion contrib  # switch to open source contribution session
    ~> ...
    ~> fishion  # switch to default session
    ~> ...
    ~> fishion -h

Prompt
======

Fishion provides an optional configurable prompt. Depending on the installation mode, enabling
the prompt may differ. The prompt is composed of different units (or parts), and the user
can choose the format of the prompt by setting the ``fishion_prompt_units`` variable.
Supported units are: ``user``, ``host``, ``vcs`` (currently only Git) and ``status`` (last command status).

.. code-block:: fish

    # fishion_prompt_units is a list of units (and other values) to format the prompt
    farzad ~/p/fishion (add-prompt)> set fishion_prompt_units user
    farzad>
    # any non-unit value in fishion_prompt_units, is used directly by the prompt
    farzad> set fishion_prompt_units user '@' host ' ' cwd vcs status
    farzad@farzad-thinkpad ~/p/fishion (add-prompt)> false
    farzad@farzad-thinkpad ~/p/fishion (add-prompt)[1]>

All prompt units can be configured to use a different color by setting variables (
either standard ``fish_color_*`` variables like ``fish_color_cwd``, or fishion specific
units like ``fishion_color_vcs``).

The prompt has implicit prefix and suffix. The values (and their colors) can be set via
variables (``fishion_prompt_prefix`` and ``fishion_color_prefix``)


Prompt variables
----------------

Here is a list of variables to customize the prompt

Customizing the prompt

* ``fishion_prompt_prefix``: content before the first prompt unit (default is session name)
* ``fishion_prompt_suffix``: content after the last prompt unit (default is ``>`` for users and ``#`` for ``root``)
* ``fishion_prompt_units``: list of units or other values to form the prompt (default is ``user @ host ' ' cwd vcs status``)

Customizing colors (see `set_color <https://fishshell.com/docs/current/cmds/set_color.html>`_)

* ``fish_color_user``: set the color for userame unit (default is green)
* ``fish_color_host``: set the color for hostname unit (default is cyan)
* ``fish_color_status``: set the color for status of last command unit (default is red)
* ``fish_color_cwd``: set the color for current working directory unit (default is green)
* ``fishion_color_vcs``: set the color for the version control system unit (default is normal)
* ``fishion_color_prefix``: set the color for the prefix (default is brblack)
* ``fishion_color_suffix``: set the color for the prefix (default is brblack)


Installation
============

``fishion`` and the prompt are fish functions, so installation means adding them
to directories where fish could find and autoload them.

For ``fishion`` it means one of the fish function library directories (system shared or user),
and for the prompt it means the user's fish functions directory.


Installation using make
-----------------------

The project's ``Makefile`` provides targets to help install/uninstall fishion. By default fishion
will be installed to a system shared path, but passing ``mode=user`` causes the target
to work with directories under user home path.
The make targets would try to find the most suitable path to install fishion.

The prompt is installed by default, but won't overwrite user's current prompt.
Instead instructions will be printed. To skip installing/uninstall the prompt,
pass ``with-prompt=no`` to the make call.

.. code-block:: fish

   # default mode is system wide, admin privileges is required, targets use sudo
   ~> make install
   ~> make uninstall

   # set mode=user to work with user home subdirectories
   ~> make install mode=user
   ~> make uninstall mode=user

   # set with-prompt=no to skip managin the prompt
   ~> make install mode=user with-prompt=no
   ~> make uninstall mode=user


Manual Installation
-------------------

For a single user installation, copy ``fishion.fish`` and/or ``fish_prompt.fish``
to user's fish functions path (usually ``~/.config/fish/functions``)

.. code-block:: fish

   ~> cp fishion.fish (realpath "$__fish_config_dir/functions/")
   # WARNING: this will overwrite existing prompt
   ~> cp -i fish_prompt.fish (realpath "$__fish_config_dir/functions/")

To install for all users of the system, copy ``fishion.fish`` to a system shared
path where `fish` would look for functions (maybe controlled by ``$XDG_DATA_DIRS``).

Copy ``fish_prompt.fish`` to where `fish_config <https://fishshell.com/docs/current/cmds/fish_config.html>`_
would store its sample prompts.

.. code-block:: fish

   ~> echo $XDG_DATA_DIRS
   /usr/local/share:/usr/share
   ~> mkdir -p /usr/share/fish/vendor_functions.d
   ~> cp fishion.fish /usr/share/fish/vendor_functions.d/
   # add prompt to list of available prompts to select using fish_config
   ~> cp fish_prompt.fish /usr/share/fish/tools/web_config/sample_prompts/fishion_prompt.fish


Sessions
========

Each session uses its own history (by setting `fish_history <https://fishshell.com/docs/current/index.html#special-variables>`_),
and can be used to customize some shell settings (prompt colors, etc.)

Sessions use universal variables, so activating a session affects all
existing open shells and new ones, until the session is changed again.

Using sessions not only helps to customize the shell settings/UI per context,
but also is an easy way to do such customization for other commands run by the
shell (for example via environment variables).

Session names can be any arbitrary value, but should only contain alphanumeric characters.

Sessions can be customized by:

#. defining initialization `functions <https://fishshell.com/docs/current/index.html#functions>`_ named after the session.
#. listing universal variable names, and providing values for such variables per session


Init Functions
--------------

Each init function name is prefixed with ``fishion_user_init_`` and ends with the session name.


For example:

.. code-block:: fish

    function fishion_user_init_work --description "init fishion work session"
        # command to run when work session is selected
        # define variables, source other files, etc.
    end

    function fishion_user_init_default --description "init fishion default session"
        # command to run when default session is selected, maybe undo/reset what other sessions did?
    end

Session Values For Universal Variables
--------------------------------------

Each session can set values for some variables, to define new variables or overwrite existing ones.
``fishion`` needs to know which variables to set, so looks up the names from the variable ``fishion_user_vars``.
This is a list of variable names.
Each session can define values for those variables by providing the value in another variable, named just
like the target variable, suffixed with the session name.

.. note::

    The variables set in this manner are all universal variables. The values
    may be set to variables with universal or global scopes, but
    the variables themselves will be universal variables after session activation.


For example:

.. code-block:: fish

   ~> set -U fishion_user_vars myvar othervar
   # now fishion will try to find values for "myvar" and "othervar" for each session
   ~> set -U myvar_work 'work work'  # the value for myvar in work session
   ~> set -U myvar_contrib 'contrib contrib'  # the value of myvar in contrib session
   ~> set -g myvar_default ''  # the value of myvar in default session

   # now switching sessions updates the values of those variables
   ~> fishion work
   ~> echo $myvar
   work work
   ~> fishion
   ~> echo $myvar

   ~> # printed empty value


Example
=======

This example demonstrates how fishion and its prompt can be used to slightly customize
a ``work`` session. The prompt style and vim settings will be different between ``work``
and ``default`` sessions.
Both init functions and session variables are used in conjunction for this example.

To change the color and the format of the fishion prompt, session init functions
set desired values for the related variables:


.. code-block:: fish

    # in file: ~/.config/fish/functions/fishion_user_init_default.fish
    function fishion_user_init_default --description "init fishion default session"
        set -U fish_color_cwd green
        set -U fishion_prompt_units user ' ' cwd status
    end


.. code-block:: fish

    # in file: ~/.config/fish/functions/fishion_user_init_work.fish
    function fishion_user_init_work --description "init fishion work session"
        set -U fish_color_cwd brblue
        set -U fishion_prompt_units cwd vcs status
    end


Now the prompt for ``default`` session looks like:


.. code-block:: fish

    farzad ~/p/fishion>


and for ``work`` session looks like:


.. code-block:: fish

    (work) ~/p/fishion (master)>


In ``work`` session user and the space after are removed from the prompt, Git branch is printed
after ``cwd``, and the default prefix shows the session name.
Also the prompts use different colors for ``cwd``.

To use different vimrc files for each session, we'll define a fish
function to call vim command passing the vimrc path from the ``VIMRC``
environment variable if exists.


.. code-block:: fish

    # file: ~/.config/fish/functions/vim.fish
    function vim --description "run vim with proper vimrc file"
        if set -q VIMRC; and test -e "$VIMRC"
            command vim -u "$VIMRC" $argv
        else
            command vim $argv
        end
    end


Then we'll set different values for this environment variable for each session,
using the session universal variables.

.. code-block:: fish

    ~> set -a -U fishion_user_vars VIMRC
    ~> set -U VIMRC_default '~/.vimrc'
    ~> set -U VIMRC_work '~/.vimrc-work'


License
-------

``fishion`` is an open source project released under the terms of the `ISC license <https://opensource.org/licenses/ISC>`_.
See LICENSE file for more details.
