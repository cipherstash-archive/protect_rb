RSpec.describe CipherStash::Protect::Model::CRUD do
  let(:ore_type) { CipherStash::Protect::ActiveRecordExtensions::ORE_64_8_V1 }

  describe "Create" do
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
end
