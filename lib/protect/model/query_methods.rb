module Protect
  module Model
    module QueryMethods
      # Intercepts the order call to update any virtual attributes to use the
      # searchable attribute field.
      # Args are an array of Symbols for default ordering and a Hash for fields noted with a direction.
      # [:age_plaintext, {:last_login=>:asc, :email=>:asc}]
      def order(*args)
        search_attrs = protect_search_attrs

        if search_attrs.nil?
          return super(*args)
        end
        updated_args =
          args.map do |arg|
            case arg
            when Symbol
              search_attr = search_attrs[arg]
              if search_attr
                search_attr.fetch(:searchable_attribute)
              else
                arg
              end
            when Hash
              updated_hash = {}
                arg.each do |field,direction|
                search_attr = search_attrs[field]
                if search_attr
                  updated_hash[search_attr.fetch(:searchable_attribute).to_sym] = direction
                else
                  updated_hash[field] = direction
                end
              end
              updated_hash
            else
              arg
            end
          end
        super(updated_args)
      end

      def select(*fields)
        return super(*fields) unless is_protected?

        modified_fields = protect_map_to_encrypted_attrs(protect_search_attrs, fields)

        super(*modified_fields)
      end

      def protect_map_to_encrypted_attrs(search_attrs, attrs)
        modified_attrs = []

        attrs.map do |attr|
          search_attr = search_attrs[attr]
          if search_attr
            modified_attrs.push(search_attrs[attr].fetch(:searchable_attribute))
            modified_attrs.push(search_attrs[attr].fetch(:lockbox_attribute).fetch(:encrypted_attribute))
          else
            attr
          end
        end

        modified_attrs
      end
    end
  end
end
