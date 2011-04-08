class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :token
      t.integer :badge
      t.integer :sr_severity
      t.boolean :note_added

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
