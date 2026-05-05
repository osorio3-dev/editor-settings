# PHP and Laravel
set -gx PATH /home/o3dev/.config/herd-lite/bin $PATH
set -gx PHP_INI_SCAN_DIR /home/o3dev/.config/herd-lite/bin $PHP_INI_SCAN_DIR

# pnpm
set -gx PNPM_HOME "/home/o3dev/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Básicos eza
alias ls="eza"
alias l="eza -lbF --git"
alias ll="eza -al --group-directories-first --icons"
alias la="eza -a"
alias lla="eza -la --group-directories-first --icons --git"

# Navegación
alias ..="cd .."
alias ...="cd ../.."

# Docker
alias docker-compose="docker compose"

# Git
alias nah="git reset --hard HEAD; and git clean -fd"

# PHP
alias cda="composer dump-autoload"

# Laravel
alias art="php artisan"
alias artm="php artisan migrate"
alias amfs="php artisan migrate:fresh --seed"
alias aqw="php artisan queue:work --timeout=0"
alias aqw1="php artisan queue:work --timeout=0 --max-jobs=1"
alias acc="php artisan cache:clear; and php artisan config:clear"
