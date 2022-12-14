require "active_support/concern"
require "uuid"

require_relative "../active_record_extensions/bloom_filter_validations"
require_relative "../analysis/token_validations"

module CipherStash
  module Protect
    module Model
      module DSL
        extend ActiveSupport::Concern

        class_methods do
          def secure_search(attribute, **options)
            if duplicate_secure_search_attribute?(protect_search_attrs, attribute)
              raise CipherStash::Protect::Error, "Attribute '#{attribute}' is already specified as a secure search attribute."
            end

            column_name = "#{attribute}_secure_search"
            type = options.delete(:type) || :string

            # Does the column exist?
            if not columns_hash.has_key?(column_name)
              # Quietly return only if we're pending DB migrations
              # (eg. in the middle of a migration run, or setting up the Rails
              #  app to start a DB migration run).
              if ActiveRecord::Base.connection.migration_context.needs_migration?
                logger.try(:debug, "Protect cannot find column '#{column_name}' on '#{self}' while pending DB migration")
                return
              else
                raise CipherStash::Protect::Error, "Column name '#{column_name}' does not exist"
              end
            end

            if !ore_64_8_v1?(column_name)
              raise CipherStash::Protect::Error, "Column name '#{column_name}' is not of type :ore_64_8_v1 (in `secure_search :#{attribute}`)"
            end

            # Check if secure_text_search has already been called before calling Lockbox has_encrypted
            # and updating protect_search_attrs with attribute
            if duplicate_secure_text_search_attribute?(protect_search_attrs, attribute)
              protect_search_attrs[attribute][:searchable_attribute] = column_name.to_s
            else
              # Call Lockbox to ensure that the underlying attribute is encrypted
              has_encrypted attribute, :type => type

              protect_search_attrs[attribute] = {
                searchable_attribute: column_name.to_s,
                type: type,
                lockbox_attribute: lockbox_attributes[attribute]
              }
            end
          end

          # TODO: Make it easier to provide options
          # eg update syntax for provided hash to remove 'kind' keys.
          def secure_text_search(attribute, **options)
            type = options.delete(:type) || :string
            column_name = "#{attribute}_secure_text_search"

            if duplicate_secure_text_search_attribute?(protect_search_attrs, attribute)
              raise CipherStash::Protect::Error, "Attribute '#{attribute}' is already specified as a secure text search attribute."
            end

            # Does the column exist?
            if not columns_hash.has_key?(column_name)
              # Quietly return only if we're pending DB migrations
              # (eg. in the middle of a migration run, or setting up the Rails
              #  app to start a DB migration run).
              if ActiveRecord::Base.connection.migration_context.needs_migration?
                logger.try(:debug, "Protect cannot find column '#{column_name}' on '#{self}' while pending DB migration")
                return
              else
                raise CipherStash::Protect::Error, "Column name '#{column_name}' does not exist"
              end
            end

            unless secure_text_search_type?(type)
              raise CipherStash::Protect::Error, "Attribute '#{attribute}' is not a valid secure_text_search type. Attribute must be of type 'string' or 'text'."
            end

            unless bloom_filter_db_type?(column_name)
              raise CipherStash::Protect::Error, "Column name '#{column_name}' is not of type 'smallint[]' (in secure_text_search :#{attribute})"
            end

            unless bloom_filter_settings?(options) && text_analysis_settings?(options)
              raise CipherStash::Protect::Error, "Invalid secure_text_search options provided in model for attribute '#{attribute}'."
            end

            unless bloom_filter_id?(options)
              raise CipherStash::Protect::Error, "Bloom filter id has not been set. Specify 'bloom_filter_id' with a valid uuid as part of the options for attribute '#{attribute}'."
            end

            # Check if secure_search has already been called before calling Lockbox has_encrypted
            # and updating protect_search_attrs with attribute.
            if duplicate_secure_search_attribute?(protect_search_attrs, attribute)
              protect_search_attrs[attribute][:searchable_text_attribute] = secure_text_search_attributes(column_name, options)
            else
              # Call Lockbox to ensure that the underlying attribute is encrypted
              has_encrypted attribute, :type => type

              protect_search_attrs[attribute] = {
                searchable_text_attribute: secure_text_search_attributes(column_name, options),
                type: type,
                lockbox_attribute: lockbox_attributes[attribute]
              }
            end
          end

          private

          def ore_64_8_v1?(column_name)
            columns_hash[column_name.to_s].sql_type_metadata.sql_type.to_sym == :ore_64_8_v1
          end

          def bloom_filter_db_type?(column_name)
            columns_hash[column_name.to_s].sql_type_metadata.sql_type == "smallint[]"
          end

          def duplicate_secure_search_attribute?(attrs, attribute)
            attrs.has_key?(attribute) && attrs[attribute].has_key?(:searchable_attribute)
          end

          def duplicate_secure_text_search_attribute?(attrs, attribute)
            attrs.has_key?(attribute) && attrs[attribute].has_key?(:searchable_text_attribute)
          end

          def secure_text_search_type?(type)
            case type
            when :string
              true
            when :text
              true
            else
              false
            end
          end

          def bloom_filter_settings?(options)
            valid_filter_options = Protect::ActiveRecordExtensions::BloomFilterValidations.valid_filter_options?(options)
            m = options.fetch(:filter_size, nil)
            k = options.fetch(:filter_term_bits, nil)

            valid_filter_options && Protect::ActiveRecordExtensions::BloomFilterValidations.valid_m?(m) && Protect::ActiveRecordExtensions::BloomFilterValidations.valid_k?(k)
          end

          def text_analysis_settings?(options)
            valid_keys = CipherStash::Protect::Analysis::TokenValidations.valid_keys?(options)
            valid_tokenizer = CipherStash::Protect::Analysis::TokenValidations.valid_tokenizer?(options)
            valid_token_filters = CipherStash::Protect::Analysis::TokenValidations.valid_token_filters?(options)

            valid_keys && valid_tokenizer && valid_token_filters
          end

          def bloom_filter_id?(options)
            options.has_key?(:bloom_filter_id) && UUID.validate(options[:bloom_filter_id])
          end

          def secure_text_search_attributes(column_name, options)
            {
              column_name.to_sym => {
                filter_size: options[:filter_size],
                filter_term_bits: options[:filter_term_bits],
                bloom_filter_id: options[:bloom_filter_id],
                tokenizer: options[:tokenizer],
                token_filters: options[:token_filters]
              }
            }
          end
        end
      end
    end
  end
end
