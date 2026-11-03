# Environment shared by interactive and non-interactive Fish.
set --global --export EDITOR nvim
set --global --export CLICOLOR 1
set --global VIRTUAL_ENV_DISABLE_PROMPT 1

if status is-interactive
    set --global fish_greeting
end
