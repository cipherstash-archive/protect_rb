module CipherStash
  module Protect
    module Analysis
      module TokenValidations
        def self.valid_keys?(options)
          options.has_key?(:tokenizer) && options.has_key?(:token_filters)
        end

        def self.valid_tokenizer?(options)
          tokenizer = options.fetch(:tokenizer, nil)

          tokenizer && tokenizer[:kind] == :standard
        end

        def self.valid_token_filters?(options)
          token_filters = options.fetch(:token_filters, nil)

          return false unless token_filters.kind_of?(Array)

          filters = token_filters.map { |obj| obj[:kind] }

          filters.include?(:downcase) || filters.include?(:ngram) && valid_token_length?(token_filters)
        end

        def self.valid_token_length?(token_filters)
          min_length = token_filters.select { |f| f.has_key?(:min_length ) }
          max_length = token_filters.select { |f| f.has_key?(:max_length ) }

          min_length.instance_of?(Integer) && max_length.instance_of?(Integer) && max_length >= min_length
        end
      end
    end
  end
end
