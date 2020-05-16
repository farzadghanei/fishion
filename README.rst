*******
Fishion
*******

`fishion` is a `fish shell <https://fishshell.com>`_ function to provide
the concept of sessions. Sessions isolate command history and allow minor
customizations. This helps to stay focused on the context of the session.


Usage
-----

.. code-block:: fish

    ~> fishion work  # switch to work session
    ~> ...
    ~> fishion contrib  # switch to open source contribution session
    ~> ...
    ~> fishion  # switch to default session
    ~> ...
    ~> fishion  -h


Installation
------------

`fishion` is a fish function, so installation means to add it to fish function library.

For a single user installation, copy the `fishion.fish` to user's fish functions path (usually `~/.config/fish/functions`)

.. code-block:: fish

   ~> cp fishion.fish (realpath "$__fish_config_dir/functions/")

To install for all users of the system, copy `fishion.fish` to a system shared
path where `fish` would look for functions (maybe controlled by `$XDG_DATA_DIRS`).

.. code-block:: fish

   ~> echo $XDG_DATA_DIRS
   /usr/local/share:/usr/share
   ~> cp fishion.fish /usr/share/fish/vendor_functions.d/


Sessions
--------
Each session uses its own history (by setting `fish_history <https://fishshell.com/docs/current/index.html#special-variables>`_),
and can be used to customize some shell settings (prompt colors, etc.)

Using sessions not only helps to customize the shell settings/UI per context,
but also is an easy way to do such customizations for other commands run by the
shell (for example via environment variables).

Session names can be any arbitrary value, but should only contain alphanumeric characters.

Sessions can be customized by defining initialization
`functions <https://fishshell.com/docs/current/index.html#functions>`_ named after the session.
Each init function name is prefixed with `fishion_user_init_` and ends with the session name.


For example:

.. code-block:: fish

    function fishion_user_init_work --description "init fishion work session"
        # command to run when work session is selected
        # define variables, source other files, etc.
    end

    function fishion_user_init_default --description "init fishion default session"
        # command to run when default session is selected, maybe undo/reset what other sessions did?
    end


License
-------

`fishion` is an open source project released under the terms of the `ISC license <https://opensource.org/licenses/ISC>`_.
See LICENSE file for more details.
