#!/bin/bash

ruby_version="1.9.3-p125"

install_ruby_build() {
  plugins_dir=$HOME/.rbenv/plugins
  if [ ! -e $plugins_dir/ruby-build ]
  then
    (
      mkdir -p $plugins_dir
      cd $plugins_dir
      git clone git://github.com/sstephenson/ruby-build.git
    )
  fi
}

brew update
brew install rbenv
install_ruby_build

set -e

install_ruby_for_chorus() {
  echo "installing ruby"
  export CC=/usr/bin/gcc
  rbenv install $ruby_version
  rbenv rehash
}

install_bundler_for_chorus() {
  echo "installing bundler"
  gem install bundler
  rbenv rehash
}

rbenv versions | grep $ruby_version || install_ruby_for_chorus
rbenv local $ruby_version
gem list | grep bundler || install_bundler_for_chorus

rbenv_config="$HOME/.bash_profile_includes/rbenv.sh"
if [ ! -e "$rbenv_config" ]
then
    cat > $rbenv_config <<EOF
#/bin/bash

eval "\$(rbenv init -)"
EOF

  echo "Added rbenv init to bash profile includes"
fi

