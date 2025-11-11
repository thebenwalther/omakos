# Environment variables

# Ruby configuration
export LDFLAGS="-L$(brew --prefix libyaml)/lib"
export CPPFLAGS="-I$(brew --prefix libyaml)/include"
export RUBY_YJIT_ENABLE=1
export RUBY_CONFIGURE_OPTS=--enable-yjit

# PostgreSQL configuration
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PGGSSENCMODE="disable"

# Local bin path
export PATH="$HOME/.local/bin:$PATH"

# Editor used by sudo
export SUDO_EDITOR="$EDITOR"
