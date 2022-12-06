RSpec.describe CipherStash::Protect::DatabaseExtensions, :type => :extensions_test do
  after(:each) do
    CipherStash::Protect::DatabaseExtensions.uninstall rescue nil
    ActiveRecord::Base.connection.execute("drop table if exists foo")
  end

  describe "Installation" do
    it "should make the ore_64_8_v1 extension type available in the database" do
      CipherStash::Protect::DatabaseExtensions.install rescue nil

      ActiveRecord::Base.connection.execute("create table foo ( email_searchable ore_64_8_v1 )")
    end
  end

  describe "Uninstallation" do
    it "should make the ore_64_8_v1 extension type unavailable in the database" do
      CipherStash::Protect::DatabaseExtensions.install rescue nil
      CipherStash::Protect::DatabaseExtensions.uninstall rescue nil

      expect {
        ActiveRecord::Base.connection.execute("create table foo ( email_searchable ore_64_8_v1 )")
      }.to raise_error ActiveRecord::StatementInvalid
    end
  end
end
