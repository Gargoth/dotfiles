function fish_prompt --description Hydro
  if test -n "$VIRTUAL_ENV_PROMPT"
    set -f venv_prompt "($VIRTUAL_ENV_PROMPT) "
  end
    echo -e "$_hydro_color_pwd$hydro_prefix_pwd$_hydro_color_pwd$_hydro_pwd$hydro_color_normal $_hydro_color_git$$_hydro_git$venv_prompt$hydro_color_normal$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$_hydro_status$hydro_color_normal "
end
