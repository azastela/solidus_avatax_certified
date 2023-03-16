# frozen_string_literal: true

require 'solidus_support'

module SolidusAvataxCertified
  class Engine < Rails::Engine
    isolate_namespace ::Spree

    engine_name 'solidus_avatax_certified'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/decorators/**/*.rb')).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
  end
end
