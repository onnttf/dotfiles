function fish_prompt --description 'Write out the prompt'
    # Capture the exit status of the last command
    set -l last_status $status

    # Define color codes for different elements in the prompt
    set -l normal (set_color normal)
    set -l status_color (set_color brgreen)
    set -l cwd_color (set_color $fish_color_cwd)
    set -l vcs_color (set_color brpurple)

    # Initialize an empty string for prompt status
    set -l prompt_status ""

    # Adjust the directory name length for a multiline prompt
    set -q fish_prompt_pwd_dir_length or set -lx fish_prompt_pwd_dir_length 0

    # Customize prompt for root user
    set -l suffix '❯'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set cwd_color (set_color $fish_color_cwd_root)
        end
        set suffix '#'
    end

    # Highlight prompt on command error
    if test $last_status -ne 0
        set status_color (set_color $fish_color_error)
        set prompt_status $status_color "[" $last_status "]" $normal
    end

    # Display the prompt with formatted elements
    echo -s $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status

    # Display command status and prompt suffix on the same line
    echo -n -s $status_color $suffix ' ' $normal
end
