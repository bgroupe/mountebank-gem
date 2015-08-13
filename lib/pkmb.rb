require "pkmb/version"
require "pkmb/helper"
require "pkmb/network"
require "pkmb/imposter"
require "pkmb/stub"
require "pkmb/stub/response"
require "pkmb/stub/http_response"
require "pkmb/stub/https_response"
require "pkmb/stub/tcp_response"
require "pkmb/stub/proxy_response"
require "pkmb/stub/predicate"
require "json"

module PkMb
  extend self

  def self.imposters
    imposters = []

    response = Network.get('/imposters')
    if response.success?
      response.body[:imposters].each do |imposter|
        imposters << PkMb::Imposter.new(imposter)
      end
    end

    imposters
  end

  def self.reset
    response = Network.delete('/imposters')
    response.success?
  end
end
