# frozen_string_literal: true
module Valkyrie::Persistence::Memory
  class Persister
    attr_reader :adapter
    delegate :cache, to: :adapter
    # @param adapter [Valkyrie::Persistence::Memory::MetadataAdapter] The memory adapter which
    #   holds the cache for this persister.
    def initialize(adapter)
      @adapter = adapter
    end

    # @param resource [Valkyrie::Resource] The resource to save.
    # @return [Valkyrie::Resource] The resource with an `#id` value generated by the
    #   persistence backend.
    def save(resource:)
      resource = generate_id(resource) if resource.id.blank?
      resource.updated_at = Time.current
      normalize_dates!(resource)
      cache[resource.id] = resource
    end

    # @param resources [Array<Valkyrie::Resource>] List of resources to save.
    # @return [Array<Valkyrie::Resource>] List of resources with an `#id` value
    #   generated by the persistence backend.
    def save_all(resources:)
      resources.map do |resource|
        save(resource: resource)
      end
    end

    # @param resource [Valkyrie::Resource] The resource to delete from the persistence
    #   backend.
    def delete(resource:)
      cache.delete(resource.id)
    end

    def wipe!
      cache.clear
    end

    private

      def generate_id(resource)
        resource.new(id: SecureRandom.uuid, created_at: Time.current)
      end

      def normalize_dates!(resource)
        resource.attributes.each { |k, v| resource.send("#{k}=", normalize_date_values(v)) }
      end

      def normalize_date_values(v)
        return v.map { |val| normalize_date_value(val) } if v.is_a?(Array)
        normalize_date_value(v)
      end

      def normalize_date_value(value)
        return value.utc if value.is_a?(DateTime)
        return value.to_datetime.utc if value.is_a?(Time)
        value
      end
  end
end