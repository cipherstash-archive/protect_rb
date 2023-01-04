module CipherStash
  module Protect
    module Query
      class MatchQueryStatistics
        # Class for generating precision and recall statistics
        # for match queries on a model.
        #
        # The secure_text_search method on the model uses a probabilistic
        # data structure called a bloom filter to store the data in.
        # https://en.wikipedia.org/wiki/Bloom_filter
        #
        # When encrypting the plaintext value into the secure_text_search field
        # 2 options are required to generate the bloom filter,
        # filter_size (m value) and filter_term_bits (k value)
        #
        # ## Example
        #
        # secure_text_search :email,
        #   filter_size: 1024, filter_term_bits: 6,
        #   bloom_filter_id: "4f108250-53f8-013b-0bb5-0e015c998817",
        #   tokenizer: { kind: :standard },
        #   token_filters: [{kind: :downcase}, {kind: :ngram, min_length: 3, max_length: 8}]
        #
        # To assist with determining what to provide for these options. This
        # class returns the below statistics.
        #
        # Precision = relevant documents retrieved / retrieved documents
        # Recall = relevant documents retrieved / relevant documents
        #
        # The precision statistic shows us how many of the total retrieved documents are relevant.
        # The recall statistic shows us how many of the total relevant documents have been retrieved.
        #
        # @param model [Class] The relevant model to apply the query to.
        #
        # @param field [Symbol] The secure_text_search field to query.
        #
        # @param query_string [String] The string to use for the query to return
        # statistic to.
        #
        # ## Example
        #
        # CipherStash::Protect::Query::MatchQueryStatistics.new({model: User, field: :email, query_string: "dann"})
        #
        def initialize(args = {})
          @model = args[:model].instance_of?(String) ? args[:model].constantize : args[:model]
          @field = args[:field].to_sym
          @query_string = args[:query_string]
        end

        def run
          retrieved_records = @model.match(@field => @query_string)

          relevant_records = retrieve_relevant_records(retrieved_records)

          relevant_retrieved_records = retrieved_records.map {|r| {id: r.id, @field => r[@field]}} & relevant_records

          total_relevant_records = total_relevant_records()

          precision = ((relevant_retrieved_records.length.to_f / retrieved_records.length) * 100).round(2)
          recall = ((relevant_retrieved_records.length.to_f / total_relevant_records.length) * 100).round(2)

          { precision: precision, recall: recall, retrieved_records: retrieved_records.map { |r| r[@field]}, total_relevant_records: total_relevant_records.map { |r| r[@field]}}
        end

        # Manually check the relevant records from the retrieved records
        # using the plaintext values for the field and the plaintext tokens.
        def retrieve_relevant_records(retrieved_records)
          searchable_text_attr = @model.protect_search_attrs[@field][:searchable_text_attribute].keys.first

          filter_options = @model.protect_search_attrs[@field][:searchable_text_attribute].fetch(searchable_text_attr)

          tokens = tokenize(@query_string, filter_options)

          records = retrieved_records.map { |r| {id: r.id, @field => r[@field] }}

          records.filter do |r|
            valid_tokens =
              tokens.filter do |t|
              r[@field].include?(t)
            end
            valid_tokens.length == tokens.length
          end
        end

        # Manually look up all records, then filter records using
        # the plaintext tokens and check that all tokens are present within each
        # plaintext field in each record.
        def total_relevant_records()
          searchable_text_attr = @model.protect_search_attrs[@field][:searchable_text_attribute].keys.first

          filter_options = @model.protect_search_attrs[@field][:searchable_text_attribute].fetch(searchable_text_attr)

          tokens = tokenize(@query_string, filter_options)

          records = @model.all

           records.filter do |r|
            valid_tokens =
              tokens.filter do |t|
              r[@field].include?(t)
            end
            valid_tokens.length == tokens.length
          end
        end

        def tokenize(value, filter_options)
          text_processor = CipherStash::Protect::Analysis::TextProcessor.new({
            token_filters: filter_options[:token_filters],
            tokenizer: filter_options[:tokenizer]
          })

          text_processor.perform(value)
        end
      end
    end
  end
end
