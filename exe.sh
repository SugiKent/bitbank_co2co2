#!/bin/bash

export PATH="/usr/local/rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv shell 2.7.1

cd ~/Dev/bitbank_co2co2
bundle exec ruby main.rb
