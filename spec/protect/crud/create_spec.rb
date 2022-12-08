RSpec.describe CipherStash::Protect::Model::CRUD do
  let(:ore_type) { CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1 }

  describe "Create secure_search record" do
    context "when using #create" do
      it "creates a single record with ore and lockbox encrypted values" do
        user = CrudTesting.create(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )

        expect(user.age_secure_search).to_not be(nil)
        expect(user.age_secure_search.class).to eq(ore_type)
        expect(user.age_secure_search.ciphertext).to_not be(nil)

        expect(user.age_ciphertext).to_not be(nil)

        returned_user = CrudTesting.where(age_secure_search: ore_type.encrypt(84))

        expect(returned_user.first.id).to eq(user.id)
      end
    end

    context "when using #create!" do
      it "creates a single record with ore and lockbox encrypted values" do
        user = CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )

        expect(user.age_secure_search).to_not be(nil)
        expect(user.age_secure_search.class).to eq(ore_type)
        expect(user.age_secure_search.ciphertext).to_not be(nil)

        expect(user.age_ciphertext).to_not be(nil)

        returned_user = CrudTesting.where(age_secure_search: ore_type.encrypt(84))

        expect(returned_user.first.id).to eq(user.id)
      end
    end

    context "when using #insert_all" do
      it "creates multiple records with ore and lockbox encrypted values" do
        CrudTesting.insert_all([
          {
            dob: Date.new(1950,9,21),
            last_login: DateTime.new(2022,10,14),
            age: 84,
            verified: true,
            latitude: 150.634496,
            email: "steve.zissou@belafonte.com"
          },
          {
            dob: Date.new(1970,6,26),
            last_login: DateTime.new(2022,10,9),
            age: 52,
            verified: false,
            latitude: 150.634496,
            email: "pt.anderson@magnolia.com"
          },
        ])

        user_one = CrudTesting.where(
          email_secure_search: ore_type.encrypt("steve.zissou@belafonte.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("steve.zissou@belafonte.com")

        user_two = CrudTesting.where(
          email_secure_search: ore_type.encrypt("pt.anderson@magnolia.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("pt.anderson@magnolia.com")
      end
    end

    context "when using #insert_all!" do
      it "creates multiple records with ore and lockbox encrypted values" do
        CrudTesting.insert_all!([
          {
            dob: Date.new(1950,9,21),
            last_login: DateTime.new(2022,10,14),
            age: 84,
            verified: true,
            latitude: 150.634496,
            email: "steve.zissou@belafonte.com"
          },
          {
            dob: Date.new(1970,6,26),
            last_login: DateTime.new(2022,10,9),
            age: 52,
            verified: false,
            latitude: 150.634496,
            email: "pt.anderson@magnolia.com"
          },
        ])

        user_one = CrudTesting.where(
          email_secure_search: ore_type.encrypt("steve.zissou@belafonte.com")
        )
        expect(user_one.length).to eq(1)
        expect(user_one.first.email_secure_search).to_not be(nil)
        expect(user_one.first.email).to eq("steve.zissou@belafonte.com")

        user_two = CrudTesting.where(
          email_secure_search: ore_type.encrypt("pt.anderson@magnolia.com")
        )

        expect(user_two.length).to eq(1)
        expect(user_two.first.email_secure_search).to_not be(nil)
        expect(user_two.first.email).to eq("pt.anderson@magnolia.com")
      end

      it "works for regular tables" do
        UnsecuredTesting.insert_all!([
          { title: "Best", counter: 5, is_true: false },
          { title: "Blurst", counter: nil, is_true: true },
        ])

        expect(UnsecuredTesting.where(title: "Best").first.counter).to be 5
        expect(UnsecuredTesting.where(is_true: true).first.counter).to be nil
      end
    end
  end

  describe "Create secure_text_search record" do
    # TODO: Update tests to verify record created via where clause when querying via bloom filter
    # has been implemented.
    VALID_BLOOM_FILTER_ID = "4f108250-53f8-013b-0bb5-0e015c998818"
    FILTER_SIZE = 256
    FILTER_TERM_BITS = 3
    TOKEN_FILTERS = [{kind: :downcase}, {kind: :ngram, token_length: 3}]
    TOKENIZER = { kind: :standard }

    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = CrudTesting.table_name

        secure_text_search :email,
          filter_size: FILTER_SIZE,filter_term_bits: FILTER_TERM_BITS,
          bloom_filter_id: VALID_BLOOM_FILTER_ID,
          tokenizer: TOKENIZER,
          token_filters: TOKEN_FILTERS
      end
    }

    let(:filter) {
      CipherStash::Protect::ActiveRecordExtensions::BloomFilter.new(VALID_BLOOM_FILTER_ID,
        {
          filter_size: FILTER_SIZE,
          filter_term_bits: FILTER_TERM_BITS
        }
      )
    }

    let(:text_processor) {
      CipherStash::Protect::Analysis::TextProcessor.new(
        {
          token_filters: TOKEN_FILTERS,
          tokenizer: TOKENIZER
        }
      )
    }

    context "when using #create" do
      it "creates a single record with bloom filter and lockbox encrypted values" do
        user = model.create(
          email: "steve.zissou@belafonte.com"
        )

        expect(user.email_secure_text_search.length).to_not be(0)
        expect(user.email_ciphertext).to_not be(nil)

        tokens = text_processor.perform("steve.zissou@belafonte.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits

        expect((bits - user.email_secure_text_search).empty?).to be(true)
      end
    end

    context "when using #create!" do
      it "creates a single record with bloom filter and lockbox encrypted values" do
        user = model.create!(
          email: "steve.zissou@belafonte.com"
        )

        expect(user.email_secure_text_search.length).to_not be(0)
        expect(user.email_ciphertext).to_not be(nil)

        tokens = text_processor.perform("steve.zissou@belafonte.com")
        bits = filter.add(tokens).postgres_bits_from_native_bits

        expect((bits - user.email_secure_text_search).empty?).to be(true)
      end
    end

    context "when using #insert_all" do
      it "creates multiple records with ore and lockbox encrypted values" do
        model.insert_all([
           { email: "steve.zissou@belafonte.com" },
           { email: "pt.anderson@magnolia.com" },
          ])

        users = model.all

        expect(users.length).to eq(2)
        users.each do |u|
          expect(u.email_secure_text_search.length).to_not be(0)
        end
      end
    end

    context "when using #insert_all!" do
      it "creates multiple records with ore and lockbox encrypted values" do
        model.insert_all!([
           { email: "steve.zissou@belafonte.com" },
           { email: "pt.anderson@magnolia.com" },
        ])

        users = model.all
        expect(users.length).to eq(2)
        users.each do |u|
          expect(u.email_secure_text_search.length).to_not be(0)
        end
      end
    end
  end
end
