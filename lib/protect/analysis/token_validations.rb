module Protect
  module Analysis
    module TokenValidations
      def self.valid_tokenizer?(obj)
        obj && obj[:kind] == :standard
      end

      def self.valid_token_filters?(arr)
        filters = arr.map { |obj| obj[:kind] }

        filters.include?(:downcase) || filters.include?(:ngram) && valid_token_length?(arr)
      end

      def self.valid_token_length?(arr)
        token_length = arr.select { |f| f.has_key?(:token_length) }

        token_length.instance_of?(Integer)
      end
    end
  end
end
