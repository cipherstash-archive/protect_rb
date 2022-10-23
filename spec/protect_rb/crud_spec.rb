RSpec.describe ProtectRB::Model::CRUD do

  describe "Create" do
    it "creates a user with ore and lockbox encrypted values" do
      user = CrudTesting.create!(
        dob: Date.new(1950,9,21),
        last_login: DateTime.new(2022,10,14),
        age: 84,
        verified: true,
        latitude: 150.634496,
        email: "steve.zissou@belafonte.com"
      )

      expect(user.age_secure_search).to_not be(nil)
      expect(user.age_secure_search.class).to eq(ProtectRB::ActiveRecordExtensions::ORE_64_8_V1)
      expect(user.age_secure_search.ciphertext).to_not be(nil)

      expect(user.age_ciphertext).to_not be(nil)

      returned_user = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(84))

      expect(returned_user.first.id).to eq(user.id)
    end
  end

  describe "Read" do
    before(:all) do
       CrudTesting.create!(
        dob: Date.new(1950,9,21),
        last_login: DateTime.new(2020,9,14),
        age: 72,
        verified: true,
        latitude: 125.634496,
        email: "steve.zissou@belafonte.com"
      )

      CrudTesting.create!(
        dob: Date.new(1947,9,22),
        last_login: DateTime.new(2022,10,12),
        age: 75,
        verified: false,
        latitude: 113.634496,
        email: "kingsley.zissou@belafonte.com"
      )

      CrudTesting.create!(
        dob: Date.new(1967,9,27),
        last_login: DateTime.new(2022,7,1),
        age: 55,
        verified: false,
        latitude: 109.634496,
        email: "royal@tenenbaum.com"
      )

      CrudTesting.create!(
        dob: Date.new(1993,3,11),
        last_login: DateTime.new(2022,8,7),
        age: 29,
        verified: true,
        latitude: 115.634496,
        email: "etheline@tenenbaum.com"
      )
    end

    it "returns records using equality on an integer type" do
      user_via_integer = CrudTesting.where(age_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(72))

      expect(user_via_integer.length).to eq(1)
      expect(user_via_integer.first.age).to eq(72)

    end

    it "returns records using equality on a boolean type" do
      user_via_boolean = CrudTesting.where(verified_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(true))

      expect(user_via_boolean.length).to eq(2)
      expect(user_via_boolean.first.verified).to eq(true)
      expect(user_via_boolean.second.verified).to eq(true)
    end

    it "returns records using equality on a date type" do
      user_via_date = CrudTesting.where(dob_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(Date.new(1967,9,27)))

      expect(user_via_date.length).to eq(1)
      expect(user_via_date.first.dob).to eq(Date.new(1967,9,27))
    end

    it "returns records using equality on a date time type" do
      user_via_datetime = CrudTesting.where(last_login_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(DateTime.new(2022,8,7)))

      expect(user_via_datetime.length).to eq(1)
      expect(user_via_datetime.first.last_login).to eq(DateTime.new(2022,8,7))
    end

    it "returns records using equality on a float type" do
      user_via_float = CrudTesting.where(latitude_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt(109.634496))

      expect(user_via_float.length).to eq(1)
      expect(user_via_float.first.latitude).to eq(109.634496)
    end

    it "returns records using equality on a string type" do
      user_via_string = CrudTesting.where(email_secure_search: ProtectRB::ActiveRecordExtensions::ORE_64_8_V1.encrypt("etheline@tenenbaum.com"))
      expect(user_via_string.length).to eq(1)
      expect(user_via_string.first.email).to eq("etheline@tenenbaum.com")
    end

    # TODO: Range queries
  end
end
