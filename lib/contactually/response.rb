module Contactually
  class Response
    extend Forwardable

    attr_reader :model_type, :raw_response, :interface

    def_delegator :raw_response, :body
    def_delegator :raw_response, :headers
    def_delegator :raw_response, :status

    def initialize(response, resource)
      @raw_response = response
      @model_type = resource.model
      @interface = resource.interface
    end

    def data
      @data ||= begin
        if is_a_collection?
          collection = raw_data.map { |item| build_from_model_type(item) }

          Collection.new(collection, meta: meta)
        else
          build_from_model_type(raw_data)
        end
      end
    end

    def raw_data
      body.fetch(DATA_KEY, {})
    end

    def errors
      body.fetch(ERROR_KEY, {})
    end

    def meta
      body.fetch(META_KEY, {})
    end

    private

    DATA_KEY = 'data'.freeze
    ERROR_KEY = 'errors'.freeze
    META_KEY = 'meta'.freeze

    def build_from_model_type(item)
      model_type.new(interface, item)
    end

    def is_a_collection?
      raw_data.is_a?(Array)
    end
  end
end
