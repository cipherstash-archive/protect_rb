RSpec.describe "A protect customer can encrypt a plaintext field to lockbox and protect encrypted fields" do
  describe "when running the migrate task" do
    it "lockbox and protect fields are migrated" do
      ActiveRecord::Base.connection.execute("INSERT INTO migration_users (email) VALUES ('test@test.com')")

      reset_user_one = MigrationTesting.first

      expect(reset_user_one.email_secure_search).to be(nil)
      expect(reset_user_one.email_ciphertext).to be(nil)

      Protect.encrypt(MigrationTesting)

      migrated_user_one = MigrationTesting.first

      expect(migrated_user_one.email_secure_search).to_not be(nil)
      expect(migrated_user_one.email_ciphertext).to_not be(nil)

      returned_user, = MigrationTesting.where(email: "test@test.com")

      expect(returned_user.email).to eq("test@test.com")
    end
  end
end
