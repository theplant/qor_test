# QorTest

  QorTest is the tool to test your library against different versions of gem dependencies and rubies (through rbenv or rvm)

[![Build Status](https://secure.travis-ci.org/qor/qor_test.png?branch=master)](http://travis-ci.org/qor/qor_test)
[![Dependency Status](https://gemnasium.com/qor/qor_test.png)](https://gemnasium.com/qor/qor_test)
[![Code Climate](https://codeclimate.com/github/qor/qor_test.png)](https://codeclimate.com/github/qor/qor_test)

## Installation

    gem install qor_test

## Usage

  QorTest require a configuration file to know those dependencies and rubies need to be tested, For example:

    # config/qor/test.rb
    env '2.0' do
      ruby '2.0'
      gem 'rails', [3.1, 3.2]
    end

    env '1.9.3' do
      ruby '1.9.3'
      gem 'rails', [3.1, 3.2]
    end

    env '1.8.7' do
      ruby '1.8.7'
      gem 'factory_girl_rails', '1.3.0'
      gem 'rails', [3.1, 3.2]
    end

  With above configuration, QorTest could generate 6 test cases.

    1, Run tests with Rails 3.1 and Ruby 2.0
    2, Run tests with Rails 3.2 and Ruby 2.0
    3, Run tests with Rails 3.1 and Ruby 1.9
    4, Run tests with Rails 3.2 and Ruby 1.9
    5, Run tests with Rails 3.1 and Ruby 1.8
    6, Run tests with Rails 3.2 and Ruby 1.8

  To run "tests" of above 6 cases, you could run `qor_test` in your project root:

      qor_test

   Or run those two cases in env '2.0' only by running

      qor_test -e '2.0'

  All dependencies definitions outside env definition will be shared in all envs, so you could simplify above configuration like below, it's the same!

    # config/qor/test.rb
    gem 'rails', [3.1, 3.2]

    env '2.0' do
      ruby '2.0'
    end

    env '1.9.3' do
      ruby '1.9.3'
    end

    env '1.8.7' do
      ruby '1.8.7'
      gem 'factory_girl_rails', '1.3.0'
    end

  Or you can write more advanced configuration:

    # config/qor/test.rb
    ruby '2.0'
    ruby '1.9.3'
    ruby '1.8.7'

    gem 'paperclip', ['2.4.2', '3.3.0', {:git => "git@github.com:thoughtbot/paperclip.git", :branch => "master"}]
    gem 'rails', [3.1, 3.2]
    gem 'devise', [2.2.0, 2.1.0, 2.0.0]

  With it, QorTest will generate 54 test cases! (3 rubies x 3 paperclip x 2 rails x 3 devise), is it dead easy to discover hidden compatibility issues?


  Running `qor_test` will use command `rake spec` to run "tests" in each case for projects using rspec and `rake test` for others. but you could specify the test command by overwrite the environment variable 'COMMAND', e.g:

    COMMAND='ruby test/xxxx.rb' qor_test

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author ##
Jinzhu <http://github.com/jinzhu>

* A Product From ThePlant <http://theplant.jp>
