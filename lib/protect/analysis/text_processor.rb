require_relative "./token_filters"
require_relative "./tokenizer"

# Copied over from the Ruby Client
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
      # Processor.new({
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
        array.map do |obj|
          case obj["kind"]
          when "downcase"
            TokenFilters::Downcase.new(obj)

          when "ngram"
            TokenFilters::NGram.new(obj)

          else
            raise "Unknown token filter: '#{obj['kind']}'"
          end
        end
      end

      def build_tokenizer(obj)
        if obj["kind"] == "standard"
          Tokenizer::Standard.new
        else
          raise "Unknown tokenizer: '#{obj['kind']}'"
        end
      end
    end
  end
end
