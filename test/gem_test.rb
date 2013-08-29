require 'minitest/autorun'
require 'qor_test'

describe Gem do
  it "gem to string" do
    # case 1
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem "rails", "3.1"
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 1
    Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "rails", "3.1"'

    # case 2
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem "rails", ["3.1", "3.2"]
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 2
    Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "rails", "3.1"'
    Qor::Test::Gem.parse(config.first("gem"))[1].to_s.must_equal 'gem "rails", "3.2"'

    # case 3
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem 'nokogiri', [{:git => "git://github.com/tenderlove/nokogiri.git", :branch => "1.4"}, {:git => "git://github.com/tenderlove/nokogiri.git"}]
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 2
    # Don't test below case with ruby 1.8 due to hash is not ordered in 1.8
    if RUBY_VERSION !~ /1.8/
      Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git", :branch=>"1.4"}'
    end
    Qor::Test::Gem.parse(config.first("gem"))[1].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git"}'

    # case 4
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem 'nokogiri', :git => "git://github.com/tenderlove/nokogiri.git", :branch => "1.4"
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 1
    if RUBY_VERSION !~ /1.8/
      Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git", :branch=>"1.4"}'
    end

    # case 5
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem 'RedCloth', ">= 4.1.0", "< 4.2.0"
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 1
    Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "RedCloth", ">= 4.1.0", "< 4.2.0"'

    # case 6
    config = Qor::Test::Configuration.load(nil, :force => true) do
      git "git://github.com/tenderlove/nokogiri.git" do
        gem 'nokogiri', '1.4'
      end
    end

    Qor::Test::Gem.parse(config.deep_find("gem")[0]).length.must_equal 1
    Qor::Test::Gem.parse(config.deep_find("gem")[0])[0].to_s.must_equal 'gem "nokogiri", "1.4", {:git=>"git://github.com/tenderlove/nokogiri.git"}'

    # case 7
    config = Qor::Test::Configuration.load(nil, :force => true) do
      git "git://github.com/tenderlove/nokogiri.git" do
        gem 'nokogiri', :branch => '1.4'
      end
    end

    Qor::Test::Gem.parse(config.deep_find("gem")[0]).length.must_equal 1
    if RUBY_VERSION !~ /1.8/
      Qor::Test::Gem.parse(config.deep_find("gem")[0])[0].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git", :branch=>"1.4"}'
    end

    # case 8
    config = Qor::Test::Configuration.load(nil, :force => true) do
      gem "rails"
    end

    Qor::Test::Gem.parse(config.first("gem")).length.must_equal 1
    Qor::Test::Gem.parse(config.first("gem"))[0].to_s.must_equal 'gem "rails"'

    # case 9
    config = Qor::Test::Configuration.load(nil, :force => true) do
      git "git://github.com/tenderlove/nokogiri.git" do
        gem 'nokogiri', ['1.4', '2.0']
      end
    end

    Qor::Test::Gem.parse(config.deep_find("gem")[0]).length.must_equal 2
    Qor::Test::Gem.parse(config.deep_find("gem")[0])[0].to_s.must_equal 'gem "nokogiri", "1.4", {:git=>"git://github.com/tenderlove/nokogiri.git"}'
    Qor::Test::Gem.parse(config.deep_find("gem")[0])[1].to_s.must_equal 'gem "nokogiri", "2.0", {:git=>"git://github.com/tenderlove/nokogiri.git"}'

    # case 10
    config = Qor::Test::Configuration.load(nil, :force => true) do
      git "git://github.com/tenderlove/nokogiri.git" do
        gem 'nokogiri', [{:branch => '1.4'}, {:branch => '2.0'}]
      end
    end

    Qor::Test::Gem.parse(config.deep_find("gem")[0]).length.must_equal 2
    if RUBY_VERSION !~ /1.8/
      Qor::Test::Gem.parse(config.deep_find("gem")[0])[0].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git", :branch=>"1.4"}'
      Qor::Test::Gem.parse(config.deep_find("gem")[0])[1].to_s.must_equal 'gem "nokogiri", {:git=>"git://github.com/tenderlove/nokogiri.git", :branch=>"2.0"}'
    end
  end
end
