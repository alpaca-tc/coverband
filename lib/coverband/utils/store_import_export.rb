# frozen_string_literal: true

module Coverband
  module Utils
    class StoreImportExport
      def initialize(store)
        @store = store
      end

      # @param [Hash] hash is Coverband::Utils::StoreImportExport#to_h
      def import(hash)
        unless hash.is_a?(Hash) && hash.key?(Coverband::EAGER_TYPE.to_s) && hash.key?(Coverband::RUNTIME_TYPE.to_s)
          raise ArgumentError, "Invalid hash format"
        end

        eager_coverage = hash[Coverband::EAGER_TYPE.to_s]
        runtime_coverage = hash[Coverband::RUNTIME_TYPE.to_s]

        @store.import(eager_coverage, runtime_coverage)
      end

      def to_h
        [Coverband::RUNTIME_TYPE, Coverband::EAGER_TYPE].to_h do |type|
          [type.to_s, @store.coverage(type, skip_hash_check: true)]
        end
      end
    end
  end
end
