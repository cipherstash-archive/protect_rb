require "active_support/concern"
require "cipherstash/protect/active_record_extensions/bloom_filter"
require "cipherstash/protect/analysis/text_processor"

module CipherStash
  module Protect
    module Model
      module CRUD
        extend ActiveSupport::Concern

        class_methods do
          def upsert_all(attributes, **options)
            super(protect_map_attributes(attributes), **options)
          end

          def insert_all(attributes, **options)
            super(protect_map_attributes(attributes), **options)
          end

          def insert_all!(attributes, **options)
            super(protect_map_attributes(attributes), **options)
          end

          def protect_map_attributes(records)
            unless records.is_a?(Array) && self.respond_to?(:lockbox_attributes)
              return records
            end

            records.map do |attributes|
              lockbox_attributes.map do |key, hash|
                virtual_attribute = hash[:attribute].to_sym
                if protect_search_attrs[virtual_attribute]

                  lockbox_encrypted_attribute = hash[:encrypted_attribute]

                  decrypted_lockbox_value = self.send("decrypt_#{lockbox_encrypted_attribute}", attributes[lockbox_encrypted_attribute])

                  secure_search_field = protect_search_attrs[virtual_attribute].fetch(:searchable_attribute, nil)
                  secure_text_search_field = protect_search_attrs[virtual_attribute].fetch(:searchable_text_attribute, nil)&.keys&.first

                  if secure_search_field
                    ore_encrypted_value = CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1.encrypt(decrypted_lockbox_value)
                    attributes[secure_search_field] = ore_encrypted_value
                  end

                  if secure_text_search_field
                    filter_options =  protect_search_attrs[virtual_attribute].fetch(:searchable_text_attribute).fetch(secure_text_search_field)

                    bloom_filter_id = filter_options.fetch(:bloom_filter_id)

                    bits = CRUD.filter_bits(bloom_filter_id, filter_options, decrypted_lockbox_value)

                    attributes[secure_text_search_field] = bits
                  end
                end
              end
              attributes
            end
          end
        end

        def _create_record(*)
          protect_sync
          super
        end

        def _update_record(*)
          protect_sync
          super
        end

        def protect_sync
          search_attrs = self.class.protect_search_attrs

          if search_attrs.kind_of?(Hash) && !search_attrs.empty?
            search_attrs.each do |virt_attr, metadata|
              searchable_attr = metadata[:searchable_attribute]
              searchable_text_attr = metadata[:searchable_text_attribute]&.keys&.first

              if searchable_attr
                self.send("#{searchable_attr}=", self.send(virt_attr))
              end

              if searchable_text_attr
                attr_value = self.send(virt_attr)
                filter_options =  metadata[:searchable_text_attribute].fetch(searchable_text_attr)
                bloom_filter_id = filter_options.fetch(:bloom_filter_id)

                bits = CRUD.filter_bits(bloom_filter_id, filter_options, attr_value)

                self.send("#{searchable_text_attr}=", bits)
              end
            end
          end
        end

        private

        def self.filter_bits(bloom_filter_id, filter_options, value)
          filter = CipherStash::Protect::ActiveRecordExtensions::BloomFilter.new(bloom_filter_id, { filter_size: filter_options[:filter_size], filter_term_bits: filter_options[:filter_term_bits] })

          text_processor = CipherStash::Protect::Analysis::TextProcessor.new({
            token_filters: filter_options[:token_filters],
            tokenizer: filter_options[:tokenizer]
          })

          tokens = text_processor.perform(value)

          bits =filter.add(tokens).to_a

          db_config = ActiveRecord::Base.connection_db_config

          if db_config.configuration_hash[:adapter] == "postgresql"
            bits =filter.postgres_bits_from_native_bits
          end

          bits
        end
      end
    end
  end
end
