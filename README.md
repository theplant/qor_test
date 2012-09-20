# QorTest

## Usage

  config/qor/test.rb

    gem  'nokogiri', [{:git => "git://github.com/tenderlove/nokogiri.git", :branch => "1.4"}, {:git => "git://github.com/tenderlove/nokogiri.git"}]

    gem  'nokogiri', :git => "git://github.com/tenderlove/nokogiri.git", :branch => "1.4"
    gem  'nokogiri', :git => "git://github.com/tenderlove/nokogiri.git"
    gem  'RedCloth', ">= 4.1.0", "< 4.2.0"

    env 'default' do
      ruby '1.9.3'
      gem  'rails', ['3.1', '3.2', '4.0.0.beta']
    end

    env '1.8.7' do
      ruby '1.8.7'
      gem  'rails', ['3.1', '3.2']
    end

  test/test_helper.rb

    load_dummy_rails_env #:models_path => [], :migrations_path => []


  Run:

    qor_test -e default -c 'ruby test/xxxx'
    qor_test -e 1.8.7 -c 'rake test'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
