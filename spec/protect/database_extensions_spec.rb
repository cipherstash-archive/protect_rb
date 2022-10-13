RSpec.describe ProtectRB::DatabaseExtensions do
  after(:each) do
    ProtectRB::DatabaseExtensions.uninstall rescue nil
    ActiveRecord::Base.connection.execute("drop table if exists foo")
  end

  describe "Installation" do
    it "should make the ore_64_8_1_v1 extension type available in the database" do
      ProtectRB::DatabaseExtensions.install

      ActiveRecord::Base.connection.execute("create table foo ( email_searchable ore_64_8_v1 )")
    end
  end
end