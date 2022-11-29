require_relative "./token_filters"
require_relative "./tokenizer"

# Implementation copied over from the Ruby Client
# https://github.com/cipherstash/ruby-client/blob/main/lib/cipherstash/analysis/text_processor.rb
module Protect
  module Analysis
    # General (but very simple) string processor
    # based on settings from a secure_text_search field in the model.
    #
    class TextProcessor
      # Creates a new string processor for the given field settings
      #
      # @param settings [Hash] the field settings
      #
      # ## Example
      #
      # TextProcessor.new({
      #   "tokenFilters"=>[
      #     {"kind"=>"downcase"},
      #     {"kind"=>"ngram", "tokenLength"=>3}
      #   ],
      #   "tokenizer"=>{"kind"=>"standard"}
      # })
      #
      def initialize(settings)
        @token_filters = build_token_filters(settings["tokenFilters"])
        @tokenizer = build_tokenizer(settings["tokenizer"])
      end

      # Processes the given str and returns an array of tokens (the "Vector")
      #
      # @param str [String] the string to process
      # @return [String]
      #
      def perform(str)
        tokens = @tokenizer.perform(str)
        @token_filters.inject(tokens) do |result, stage|
          stage.perform(result)
        end
      end

      private
      def build_token_filters(array)
        raise Protect::Error, "No token filters provided." unless array && array.length > 0
        array.map do |obj|
          case obj["kind"]
          when "downcase"
            TokenFilters::Downcase.new(obj)

          when "ngram"
            raise Protect::Error, "Token length not provided. Please specify token length using '{'kind'=>'ngram', 'tokenLength'=>3}'" unless obj["tokenLength"]

            TokenFilters::NGram.new(obj)

          else
            raise Protect::Error, "Unknown token filter: '#{obj['kind']}'"
          end
        end
      end

      def build_tokenizer(obj)
        raise Protect::Error, "No tokenizer provided. Use 'tokenizer'=>{'kind'=>'standard'} in your settings." unless obj

        if obj["kind"] == "standard"
          Tokenizer::Standard.new
        else
          raise Protect::Error, "Unknown tokenizer: '#{obj['kind']}'. Use 'tokenizer'=>{'kind'=>'standard'} in your settings."
        end
      end
    end
  end
end
