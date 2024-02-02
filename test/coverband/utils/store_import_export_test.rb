# frozen_string_literal: true

require File.expand_path("../../test_helper", File.dirname(__FILE__))

module Coverband
  module Utils
    class StoreImportExportTest < ::Minitest::Test
      def setup
        super
        @store = Coverband.configuration.store
        @store_import_export = StoreImportExport.new(@store)
      end

      def test_export_empty
        assert_equal({ Coverband::RUNTIME_TYPE.to_s => {}, Coverband::EAGER_TYPE.to_s => {} }, @store_import_export.to_h)
      end

      def test_export_with_runtime_coverage
        mock_file_hash
        coverage = basic_coverage
        @store.type = Coverband::RUNTIME_TYPE
        @store.save_report(coverage)

        result = @store_import_export.to_h
        key = coverage.keys.first

        assert_equal({}, result[Coverband::EAGER_TYPE.to_s])
        assert_equal coverage.keys, result[Coverband::RUNTIME_TYPE.to_s].keys
        assert_equal coverage[key], result[Coverband::RUNTIME_TYPE.to_s][key]['data']
        assert_equal 'abcd', result[Coverband::RUNTIME_TYPE.to_s][key]['file_hash']
      end

      def test_export_with_eager_loading_coverage
        mock_file_hash
        coverage = basic_coverage
        @store.type = Coverband::EAGER_TYPE
        @store.save_report(coverage)

        result = @store_import_export.to_h
        key = coverage.keys.first

        assert_equal({}, result[Coverband::RUNTIME_TYPE.to_s])
        assert_equal coverage.keys, result[Coverband::EAGER_TYPE.to_s].keys
        assert_equal coverage[key], result[Coverband::EAGER_TYPE.to_s][key]['data']
        assert_equal 'abcd', result[Coverband::EAGER_TYPE.to_s][key]['file_hash']
      end

      def test_import_with_coverage
        mock_file_hash

        coverage = basic_coverage
        @store.type = Coverband::EAGER_TYPE
        @store.save_report(coverage)
        @store.type = Coverband::RUNTIME_TYPE
        @store.save_report(coverage)

        result = @store_import_export.to_h
        @store.clear!

        assert_equal({ Coverband::RUNTIME_TYPE.to_s => {}, Coverband::EAGER_TYPE.to_s => {} }, @store_import_export.to_h)
        @store_import_export.import(result)
        assert_equal result, @store_import_export.to_h
      end

      def test_import_with_invalid_coverage
        assert_raises(ArgumentError) do
          @store_import_export.import(nil)
        end

        assert_raises(ArgumentError) do
          @store_import_export.import({})
        end
      end
    end
  end
end
