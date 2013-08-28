# Qor Test

  Qor Test is the tool to test your library against different versions of gem dependencies and rubies (through rbenv or rvm)

  Make it easy to discovery compatibility issues!

[![Build Status](https://secure.travis-ci.org/qor/qor_test.png?branch=master)](http://travis-ci.org/qor/qor_test)
[![Dependency Status](https://gemnasium.com/qor/qor_test.png)](https://gemnasium.com/qor/qor_test)
[![Code Climate](https://codeclimate.com/github/qor/qor_test.png)](https://codeclimate.com/github/qor/qor_test)

## Installation

    gem install qor_test

## Quick Start

  Qor Test require a configuration file to know those dependencies and rubies you would like to test, Here is a sample configuration:

    # config/qor/test.rb
    env '2.0' do
      ruby '2.0'
      gem 'rails', [3.1, 3.2, 4.0]
    end

    env '1.8.7' do
      ruby '1.8.7'
      gem 'rails', [3.1, 3.2]
    end

  With the above configuration, Qor Test could generate 5 test scenes.

    1, Test your project with Rails 3.1 and Ruby 2.0
    2, Test your project with Rails 3.2 and Ruby 2.0
    3, Test your project with Rails 4.0 and Ruby 2.0
    4, Test your project with Rails 3.1 and Ruby 1.8
    5, Test your project with Rails 3.2 and Ruby 1.8

  In order to test your project in all above 5 scenes, You could simply run

    qor_test

  Of course, you could specify a scene to test your project, for example, use `qor_test -e '2.0'` to test your project only with ruby 2.0.

## Advanced Usage

  \* Dependencies defined outside would be shared in all scenes:

  So you could write below configuration to test your project with rails 3.1, 3.2 in ruby 1.8, 1.9, 2.0. (6 scenes)

    # config/qor/test.rb
    gem 'rails', [3.1, 3.2]

    env '1.9+' do
      ruby ['1.9.3', '2.0']
    end

    env '1.8.7' do
      ruby '1.8.7'
      gem 'factory_girl_rails', '1.3.0'
    end

 \* Gemfile options `git`, `branch`, `path` and so on is supported by Qor Test

    # config/qor/test.rb
    ruby ['2.0', '1.9.3', '1.8.7']
    gem 'paperclip', ['2.4.2', '3.3.0', {:git => "git@github.com:thoughtbot/paperclip.git", :branch => "master"}]
    gem 'rails', [3.1, 3.2, 4.0]

\* RSpec is supported

  Qor Test will invoke `rake spec` to run tests for rspec projects.

  And you could even specify a test command by passing environment variable 'COMMAND'. For Example:

    COMMAND='ruby test/xxxx.rb' qor_test

## Screenshot for testing Qor Test with Qor Test

[![Qor Test](https://raw.github.com/qor/qor_test/master/test/screenshot.png)](https://raw.github.com/qor/qor_test/master/test/screenshot.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Credits
#### Author: Jinzhu <http://github.com/jinzhu>

#### A Product From ThePlant  <http://theplant.jp>
