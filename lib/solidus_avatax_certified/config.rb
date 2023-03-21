# frozen_string_literal: true

AVATAX_HEADERS = { 'X-Avalara-Client' => ENV["AVATAX_CLIENT_ID"] }.freeze

module SolidusAvataxCertified
  class AvataxConfiguration < ::Spree::Preferences::Configuration
    preference :company_code, :string, default: proc { ENV['AVATAX_COMPANY_CODE'] }
    preference :account, :string, default: proc { ENV['AVATAX_ACCOUNT'] }
    preference :password, :string, default: proc { ENV['AVATAX_PASSWORD'] }
    preference :license_key, :string, default: proc { ENV['AVATAX_LICENSE_KEY'] }
    preference :environment, :string, default: proc { ENV.fetch('AVATAX_ENVIRONMENT', Rails.env.production? ? 'production' : 'sandbox') }
    preference :log, :boolean, default: true
    preference :log_to_stdout, :boolean, default: false
    preference :address_validation, :boolean
    preference :address_validation_enabled_countries, :array, default: ['United States', 'Canada']
    preference :tax_calculation, :boolean, default: true
    preference :document_commit, :boolean, default: true
    preference :origin, :string, default: '{}'
    preference :refuse_checkout_address_validation_error, :boolean
    preference :customer_can_validate, :boolean, default: false
    preference :raise_exceptions, :boolean, default: false

    def self.boolean_preferences
      %w(tax_calculation document_commit log log_to_stdout address_validation refuse_checkout_address_validation_error customer_can_validate raise_exceptions)
    end

    def self.storable_env_preferences
      %w(company_code account license_key environment)
    end
  end

  Config = AvataxConfiguration.new
end

module Spree
  module Avatax
    include ActiveSupport::Deprecation::DeprecatedConstantAccessor

    deprecate_constant 'Config', 'SolidusAvataxCertified::Config'
  end
end
