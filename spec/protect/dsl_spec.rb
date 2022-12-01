RSpec.describe Protect::Model::DSL do
  describe "class_methods" do
    context "secure_search" do
      let(:model) {
        Class.new(ActiveRecord::Base) do
          self.table_name = DslTesting.table_name

          secure_search :dob, type: :date
        end
      }

      it "raises an error when a secure_search attribute is not of type :ore_64_8_v1" do
        expect {
          model.secure_search :email
        }.to raise_error(Protect::Error,  "Column name 'email_secure_search' is not of type :ore_64_8_v1 (in `secure_search :email`)")
      end

      it "raises an error when secure_search has already been specified for an attribute" do
        expect {
          model.secure_search :dob
        }.to raise_error(Protect::Error, "Attribute 'dob' is already specified as a secure search attribute.")
      end

      it "allows for secure_search to be specified on an attribute" do
        expect {
          model.secure_search :full_name
        }.to_not raise_error
      end

      context "when a secure_search attribute does not exist" do
        it "raises an error if there are no pending migrations" do
          expect {
            Class.new(ActiveRecord::Base) do
              self.table_name = DslTesting.table_name
              secure_search :unicorn, type: :string
            end
          }.to raise_error(Protect::Error, "Column name 'unicorn_secure_search' does not exist")
        end

        it "silently logs if there are pending migrations" do
          allow_any_instance_of(ActiveRecord::MigrationContext).to(
            receive(:needs_migration?).and_return(true)
          )

          logger = Logger.new(IO::NULL)
          expect(logger).to receive(:debug).with(/Protect cannot find column 'unicorn_secure_search' on '[^']+'/)
          ActiveRecord::Base.logger = logger

          Class.new(ActiveRecord::Base) do
            self.table_name = DslTesting.table_name
            secure_search :unicorn, type: :string
          end
        end
      end
    end

    context "secure_text_search" do
      let(:model) {
        Class.new(ActiveRecord::Base) do
          self.table_name = DslTesting.table_name
        end
      }

      let(:model_text_search) {
        Class.new(ActiveRecord::Base) do
          self.table_name = DslTesting.table_name

          secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        end
      }

      it "raises an error when secure_text_search has already been specified for an attribute" do
        expect {
          model_text_search.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3, tokenizer: :standard, token_filters: []

        }.to raise_error(Protect::Error, "Attribute 'full_name' is already specified as a secure text search attribute.")
      end

      it "raises an error when secure_text_search is specified on a non text attribute" do
        expect {
          model.secure_text_search :dob, type: :date
        }.to raise_error(Protect::Error, "Attribute 'dob' is not a valid type. Attribute must be of type 'string' or 'text'.")
      end

      it "raises an error when secure_text_search attribute is not db data type 'smallint[]'" do
        expect {
          model.secure_text_search :email
        }.to raise_error(Protect::Error, "Column name 'email_secure_text_search' is not of type 'smallint[]' (in secure_text_search :email)")
      end

      it "raises an error when no bloom filter or text analysis settings are provided" do
        expect {
          model.secure_text_search :full_name
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when no bloom filter settings are provided" do
        expect {
          model.secure_text_search :full_name,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when no text analysis settings are provided" do
        expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when invalid filter values are provided" do
        expect {
          model.secure_text_search :full_name, filter_size: 31, filter_term_bits: 3,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")

        expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 17,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when an invalid tokenizer is provided" do
        expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
          tokenizer: { kind: :non_standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when an invalid token filter is provided" do
        expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :invalid_filter}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      it "raises an error when an ngram filter is specified without token_length" do
       expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :ngram}
          ]
        }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
      end

      ["3", nil, { test: "something"}, "test", Object.new].each do |t|
        it "raises an error when an ngram filter is specified with an invalid token_length #{t.inspect}" do
          expect {
            model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
            tokenizer: { kind: :standard },
            token_filters: [
              {kind: :ngram, token_length: t}
            ]
          }.to raise_error(Protect::Error, "Invalid secure_text_search options provided in model for attribute 'full_name'.")
        end
      end

      it "allows for secure_text_search to be specified on a text attribute" do
        expect {
          model.secure_text_search :full_name, filter_size: 256, filter_term_bits: 3,
          tokenizer: { kind: :standard },
          token_filters: [
            {kind: :downcase},
            {kind: :ngram, token_length: 3}
          ]
        }.to_not raise_error
      end
    end
  end
end
