class CreateRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects do |t|
      t.string :name
      t.string :subdomain
      t.string :url
    end
  end

  def self.down
    drop_table :redirects
  end
end
