class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :username  # login name
      t.string  :firstname  # for display, communication
      t.string  :lastname
      t.string  :email
      t.string  :phone1
      t.string  :phone2
      t.string  :timezone
      t.string  :password_hash
      t.string  :password_salt
      t.integer :reputation, :default => 1
      t.string  :locale, :default => 'en_US'
      t.boolean :is_admin, :default => false # content hub admin
      t.boolean :is_deleted, :default => false
      t.integer :access_level, :default => '10'
      t.timestamps
    end
  end
  
  def self.down
    drop_table :users
  end
end
