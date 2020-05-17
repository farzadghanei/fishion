#!/usr/bin/env fish

# ISC License (ISC)
# Copyright 2020 Farzad Ghanei
#
# Permission to use, copy, modify, and/or distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright notice and
# this permission notice appear in all copies.
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD
# TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# fishion enables fish sessions. sessions isolate history and allow minor customizations
function fishion --description "select a fish session"
    if contains -- '-h' $argv; or contains -- '--help' $argv
        echo "fishion enables fish sessions. sessions isolate history and "
        echo "allow minor customizations"
        echo "usage: fishion [options] [session]"
        echo "options"
        echo "  -h, --help      show this help and exit"
        echo "  -v, --version   print fishion version and exit"
        echo "if no session name is passed, it will be 'default'."
        echo "names can have alphanumeric characters only"
        echo "session configuring and initialization:"
        echo '  fishion_user_init_$session: function to init the session'
        echo '  fishion_user_vars: list of universal variable names to set'
        echo '    values are picked from $varname_$session. example:'
        echo '    set -U fishion_user_vars myvar'
        echo '    set -U myvar_work "value of myvar in work session"'
        return 0
    end
    if contains -- '-v' $argv; or contains -- '--version' $argv
        echo '0.0.1'
        return 0
    end

    set -l session $argv[1]
    if test -z "$session"
        set session default
    end

    if string match -q --invert --regex -- '^[[:alnum:]]+$' "$session"
        echo "session names should only contain alphanumeric characters" >&2
        return 65
    end

    # keep the default fish greeting so fish_greeting can be reset
    if test -z $_fishion_default_fish_greeting
        set -U _fishion_default_fish_greeting $fish_greeting
    end

    # integrations with fish itself
    if test "$session" = default
        echo "resetting to default session ..."
        set -U -e fishion_name
        set -U -e fish_history
        set -U fish_greeting "$_fishion_default_fish_greeting"
    else
        echo "switching to fish session $session ..."
        set -U fishion_name $session
        set -U fish_history $session
        set -U fish_greeting "$_fishion_default_fish_greeting (session: $session)"
    end

    # call session init function, if defined
    set -l session_init fishion_user_init_"$session"
    if functions -q "$session_init"
        $session_init
    end

    # populate selected user variables with values set for session
    # $fishion_user_vars stores list of variable names, that each session can
    # overwrite the value.
    set -l _varname ''
    for _varname in $fishion_user_vars
        set -l _varname_for_session "$_varname"_"$session"
        if set --query $_varname_for_session  # session has an overwrite for _varname
            set -l _val_in_session $$_varname_for_session  # dereference to get the overwriting value
            set -U $_varname "$_val_in_session"
        end
    end
end
