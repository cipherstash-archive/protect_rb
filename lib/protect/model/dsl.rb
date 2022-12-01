require "active_support/concern"
require "protect/active_record_extensions/bloom_filter_validations"

module Protect
  module Model
    module DSL
      extend ActiveSupport::Concern
      class_methods do
        def secure_search(attribute, **options)
          if duplicate_secure_search_attribute?(protect_search_attrs, attribute)
            raise Protect::Error, "Attribute '#{attribute}' is already specified as a secure search attribute."
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
              raise Protect::Error, "Column name '#{column_name}' does not exist"
            end
          end

          if !ore_64_8_v1?(column_name)
            raise Protect::Error, "Column name '#{column_name}' is not of type :ore_64_8_v1 (in `secure_search :#{attribute}`)"
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

        def secure_text_search(attribute, **options)
          type = options.delete(:type) || :string
          column_name = "#{attribute}_secure_text_search"

          if duplicate_secure_text_search_attribute?(protect_search_attrs, attribute)
            raise Protect::Error, "Attribute '#{attribute}' is already specified as a secure text search attribute."
          end

          unless secure_text_search_type?(type)
            raise Protect::Error, "Attribute '#{attribute}' is not a valid type. Attribute must be of type 'string' or 'text'."
          end

          unless bloom_filter_db_type?(column_name)
            raise Protect::Error, "Column name '#{column_name}' is not of type 'smallint[]' (in secure_text_search :#{attribute})"
          end

          unless bloom_filter_settings?(options) && text_analysis_settings?(options)
            raise Protect::Error, "Invalid secure_text_search options provided in model for attribute '#{attribute}'."
          end

          # Check if secure_search has already been called before calling Lockbox has_encrypted
          # and updating protect_search_attrs with attribute.
          if duplicate_secure_search_attribute?(protect_search_attrs, attribute)
            protect_search_attrs[attribute][:searchable_text_attribute] = column_name.to_s
          else
            # Call Lockbox to ensure that the underlying attribute is encrypted
            has_encrypted attribute, :type => type

            protect_search_attrs[attribute] = {
              searchable_text_attribute: column_name.to_s,
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
          valid_filter_options = BloomFilterValidations.valid_filter_options?(options)
          m = options.fetch(:filter_size, nil)
          k = options.fetch(:filter_term_bits, nil)

          valid_filter_options && BloomFilterValidations.valid_m?(m) && BloomFilterValidations.valid_k?(k)
        end

        def text_analysis_settings?(options)
          valid_keys = options.has_key?(:tokenizer) && options.has_key?(:token_filters)

          valid_tokenizer = valid_tokenizer?(options[:tokenizer])
          valid_token_filters = options[:token_filters].kind_of?(Array) && valid_token_filters?(options[:token_filters])
        end

        def valid_tokenizer?(obj)
          obj && obj[:kind] == :standard
        end

        def valid_token_filters?(arr)
          filters = arr.map { |obj| obj[:kind] }

          filters.include?(:downcase) || filters.include?(:ngram) && valid_token_length(arr)
        end

        def valid_token_length?(arr)
          token_length = arr.select { |f| f.has_key?(:token_length)}

          token_length.instance_of?(Integer)
        end
      end
    end
  end
end
