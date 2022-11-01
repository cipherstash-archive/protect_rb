RSpec.describe "ProtectRB master key" do
  describe "cs_protect_key" do
    context "nil value" do
      before(:each) do
        ENV['CS_PROTECT_KEY'] = nil
      end

      after(:each) do
         ENV['CS_PROTECT_KEY'] = ProtectRB.generate_key
      end

      it "raises an error" do
        expect{CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )}.to raise_error(ProtectRB::Error, "Invalid CS_PROTECT_KEY. Use ProtectRB.generate_key to create a key.")
      end
    end

    context "Incorrect length" do
      before(:each) do
        ENV['CS_PROTECT_KEY'] = "e215e5d67c561e93ebe4fb174a83c2121ad470c56b58b350"
      end

      after(:each) do
         ENV['CS_PROTECT_KEY'] = ProtectRB.generate_key
      end

      it "raises an error" do
        expect{CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )}.to raise_error(ProtectRB::Error, "Invalid CS_PROTECT_KEY. Use ProtectRB.generate_key to create a key.")
      end
    end

    context "Invalid hex characters" do
      before(:each) do
        ENV['CS_PROTECT_KEY'] = "*cf6123618bc807361be073728a076fb01b65a4b9685dc69b8decca4773ccdd8"
      end

      after(:each) do
         ENV['CS_PROTECT_KEY'] = ProtectRB.generate_key
      end

      it "raises an error" do
        expect{CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )}.to raise_error(ProtectRB::Error, "Invalid CS_PROTECT_KEY. Use ProtectRB.generate_key to create a key.")
      end
    end

    context "Valid key" do
      before(:each) do
        ENV['CS_PROTECT_KEY'] = "4cf6123618bc807361be073728a076fb01b65a4b9685dc69b8decca4773ccdd8"
      end

      after(:each) do
         ENV['CS_PROTECT_KEY'] = ProtectRB.generate_key
      end

      it "does not raise an error" do
        expect{CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )}.to_not raise_error()
      end
    end
  end

  describe "Lockbox master key", :focus do
    context "Nil value" do
      before(:each) do
        Lockbox.master_key = nil
        ENV['LOCKBOX_MASTER_KEY'] = nil
      end

      after(:each) do
        ENV['LOCKBOX_MASTER_KEY'] = Lockbox.generate_key
      end

      it "raises an error" do
        expect{CrudTesting.create!(
          dob: Date.new(1950,9,21),
          last_login: DateTime.new(2022,10,14),
          age: 84,
          verified: true,
          latitude: 150.634496,
          email: "steve.zissou@belafonte.com"
        )}.to raise_error(ArgumentError, "Missing master key")
      end
    end
  end
end
