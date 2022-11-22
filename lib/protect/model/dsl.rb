require "active_support/concern"

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

          # Call Lockbox to ensure that the underlying attribute is encrypted
          has_encrypted attribute, :type => type

          if !ore_64_8_v1?(column_name)
            raise Protect::Error, "Column name '#{column_name}' is not of type :ore_64_8_v1 (in `secure_search :#{attribute}`)"
          end

          protect_search_attrs[attribute] = {
            searchable_attribute: column_name.to_s,
            type: type,
            lockbox_attribute: lockbox_attributes[attribute]
          }
        end

        private

        def ore_64_8_v1?(column_name)
          columns_hash[column_name.to_s].sql_type_metadata.sql_type.to_sym == :ore_64_8_v1
        end

        def duplicate_secure_search_attribute?(attrs, attribute)
          attrs.has_key?(attribute)
        end
      end
    end
  end
end
