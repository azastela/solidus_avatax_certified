# frozen_string_literal: true

module SolidusAvataxCertified
  class AvataxClient
    AUTH_TYPES = { password: { name: "pass_auth" }, api_key: { name: "api_key_auth" } }.freeze

    def client
      @client ||=
        if auth_type == AUTH_TYPES[:password][:name]
          ::Avatax::Client.new(
            username: account,
            password: password,
            env: environment,
            headers: AVATAX_HEADERS
          )
        elsif auth_type == AUTH_TYPES[:api_key][:name]
          ::Avatax::Client.new(
            env: environment,
            headers: avatax_headers
          )
        end
    end

    private

    def auth_type
      @auth_type ||=
        if password
          AUTH_TYPES[:password][:name]
        elsif license_key
          AUTH_TYPES[:api_key][:name]
        else
          raise ArgumentError, 'AVATAX_PASSWORD or AVATAX_LICENSE_KEY is missing'
        end
    rescue ArgumentError => e
      logger.error e
    end

    def avatax_headers
      if auth_type == AUTH_TYPES[:password][:name]
        AVATAX_HEADERS
      else
        api_key_auth_headers
      end
    end

    def api_key_auth_headers
      AVATAX_HEADERS.merge({ 'Authorization' => auth_header_value })
    end

    def auth_header_value
      "Basic #{token}"
    end

    def token
      Base64.encode64(token_data)
    end

    def token_data
      "#{account}:#{license_key}"
    end

    def license_key
      config.license_key
    end

    def account
      config.account
    end

    def environment
      config.environment
    end

    def password
      config.password
    end

    def config
      Spree::Avatax::Config
    end
  end
end
