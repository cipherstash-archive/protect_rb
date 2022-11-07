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
    end
  end
end
