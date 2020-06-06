# name: fishion
# author: Farzad Ghanei

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

# fish_prompt integrated with fishion. fishion enables fish sessions.
function fish_prompt --description 'Write out the prompt'
        set -l last_status $status
        set -l color_normal (set_color normal)

        if not set -q __fishion_prompt_colors_initialized
            # standard fish prompt colors
            set -qU fish_color_user; or set -U fish_color_user -o green
            set -qU fish_color_host; or set -U fish_color_host -o cyan
            set -qU fish_color_status; or set -U fish_color_status red
            set -qU fish_color_cwd; or set -U fish_color_cwd green
            # fishion prompt specific colors
            set -qU fishion_color_prefix; or set -U fishion_color_prefix brblack
            set -qU fishion_color_suffix; or set -U fishion_color_suffix brblack
            set -qU fishion_color_vcs; or set -U fishion_color_vcs normal
            set -U __fishion_prompt_colors_initialized
        end

        set -l __prompt_status
        if test $last_status -ne 0
            set __prompt_status (set_color $fish_color_status) "[$last_status]" "$color_normal"
        end


        # Default fishion prompt has multiple units. To control the prompt
        # set the units in $fishion_prompt_units variable, in order.
        # Any unknown value in this list is used directly, which is helpful to customize
        # how units are separated.
        # The prompt always has a prefix and a suffix.
        # All units and prefix/suffix use variables for colors.
        # Available units: user host cwd vcs status

        # cache the prompt hostname
        if not set -q __fishion_prompt_hostname
            set -g __fishion_prompt_hostname (hostname|cut -d . -f 1)
        end

        # default prefix informs session name
        if not set -q fishion_prompt_prefix
            if set -qU fishion_name
                set fishion_prompt_prefix "($fishion_name) "
            else
                set fishion_prompt_prefix
            end
        end

        # cwd color and default suffix are set based on user
        set -l color_cwd
        set -l suffix
        switch $USER
            case root toor
                    if set -q fish_color_cwd_root
                        set color_cwd $fish_color_cwd_root
                    else
                        set color_cwd $fish_color_cwd
                    end
                    set suffix '#'
            case '*'
                    set color_cwd $fish_color_cwd
                    set suffix '>'
        end

        set -q fishion_prompt_suffix; or set -l fishion_prompt_suffix "$suffix "
        set -q fishion_prompt_units; or set -l fishion_prompt_units user @ host ' ' cwd vcs status

        # construct the prompt
        set -l __prompt_prefix (set_color $fishion_color_prefix)$fishion_prompt_prefix
        set -l __prompt_user (set_color $fish_color_user)$USER # compat with standard fish_color_user
        set -l __prompt_host (set_color $fish_color_host)$__fishion_prompt_hostname # compat with standard fish_color_host
        set -l __prompt_cwd (set_color $color_cwd)(prompt_pwd)
        set -l __prompt_vcs (set_color $fishion_color_vcs)(__fish_git_prompt)
        set -l __prompt_suffix (set_color $fishion_color_suffix)$fishion_prompt_suffix

        set _l __prompt __prompt_prefix
        for unit in $fishion_prompt_units
            set -l unit_varname "__prompt_$unit"
            if set -q $unit_varname
                set --append __prompt $$unit_varname
            else
                set --append __prompt $color_normal $unit  # non variable units join the prompt directly
            end
        end

        echo -n -s $color_normal $__prompt_prefix $__prompt $color_normal $__prompt_suffix $color_normal
end
