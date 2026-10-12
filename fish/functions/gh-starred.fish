function gh-starred --description "List starred GitHub repositories"
    if not command -q gh
        echo "gh-starred requires the GitHub CLI (gh)." >&2
        return 127
    end
    gh api user/starred --template '{{range .}}{{.full_name|color "yellow"}} ({{timeago .updated_at}}){{"\n"}}{{end}}'
end
