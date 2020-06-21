=======
Fishion
=======

-----------------------------
fishion enables fish sessions
-----------------------------

:Author: Farzad Ghanei <farzad.ghanei@tutanota.com>
:Date:   2020-06-21
:Copyright:  Copyright (c) 2020 Farzad Ghanei. fishion is an open source project released under the terms of the ISC license.
:Version: 0.1.0
:Manual section: 1


SYNOPSIS
========
    fishion [session_name]


DESCRIPTION
===========
fishion is a fish shell function to provide the concept of sessions.
Sessions isolate command history and allow minor customization.
This helps to stay focused on the context of the session.

Each session uses its own history (by setting **fish_history**),
and can be used to customize some shell settings (prompt colors, etc.)
Sessions use universal variables, so activating a session affects all
existing open shells and new ones, until the session is changed again.
Session names can be any arbitrary value, but should only contain alphanumeric characters.


Session Customization
---------------------

Sessions can be customized by:

#. defining initialization functions named after the session.
#. listing universal variable names, and providing values for such variables per session

**init functions**:
Each init function name is prefixed with **fishion_user_init_** and
ends with the session name.

.. code-block:: fish

    function fishion_user_init_work --description "init fishion work session"
        # command to run when work session is selected
        # define variables, source other files, etc.
    end

To init the "default" session (when no session name is provided):

.. code-block:: fish

    function fishion_user_init_default --description "init fishion default session"
        # command to run when default session is selected, maybe undo/reset what other sessions did?
    end


**session universal variables**:
Each session can set values for variables, to define new variables or overwrite existing ones.
fishion needs to know which variables to set, so looks up the names from the variable
**fishion_user_vars**. This is a list of variable names.

Each session can define values for those variables by providing the value in another variable, named just
like the target variable, suffixed with the session name.

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


Fishion Prompt
--------------
Fishion provides an optional configurable prompt, composed of different units.
The user can choose the format of the prompt by setting the **fishion_prompt_units** variable.

Supported units are: **user**, **host**, **vcs** (currently only Git) and **status**
(last command status).
The prompt has implicit prefix and suffix. The values (and their colors) can be set via
variables (**fishion_prompt_prefix** and **fishion_color_prefix**)

.. code-block:: fish

    # fishion_prompt_units is a list of units (and other values) to format the prompt
    farzad ~/p/fishion (add-prompt)> set fishion_prompt_units user
    farzad>
    # any non-unit value in fishion_prompt_units, is used directly by the prompt
    farzad> set fishion_prompt_units user '@' host ' ' cwd vcs status
    farzad@localhost ~/p/fishion (add-prompt)> false
    farzad@localhost ~/p/fishion (add-prompt)[1]>

All prompt units can be configured to use a different color by setting variables (
either standard **fish_color_*** variables like **fish_color_cwd**, or fishion specific
units like **fishion_color_vcs**).

**Prompt variables**

* **fishion_prompt_prefix**: content before the first prompt unit (default is session name)
* **fishion_prompt_suffix**: content after the last prompt unit (default is **>** for users and **#** for **root**)
* **fishion_prompt_units**: list of units or other values to form the prompt (default is **user @ host ' ' cwd vcs status**)
* **fish_color_user**: set the color for userame unit (default is green)
* **fish_color_host**: set the color for hostname unit (default is cyan)
* **fish_color_status**: set the color for status of last command unit (default is red)
* **fish_color_cwd**: set the color for current working directory unit (default is green)
* **fishion_color_vcs**: set the color for the version control system unit (default is normal)
* **fishion_color_prefix**: set the color for the prefix (default is brblack)
* **fishion_color_suffix**: set the color for the prefix (default is brblack)


Example
=======
This example demonstrates how fishion and its prompt can be used
to slightly customize a "work" session. The prompt style and vim settings will be
different between "work" and "default" sessions.
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


Now the prompt for default session looks like:

    *farzad ~/p/fishion>*

and for work session looks like:

    *(work) ~/p/fishion (master)>*


In work session, user and the space after are removed from the prompt, Git branch is printed
after cwd, and the default prefix shows the session name.
Also the prompts use different colors for *cwd*.

To use different vimrc files for each session, we'll define a fish
function to call vim command passing the vimrc path from an environment
variable if exists.


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


REPORTING BUGS
==============
Bugs can be reported with https://github.com/farzadghanei/fishion/issues
