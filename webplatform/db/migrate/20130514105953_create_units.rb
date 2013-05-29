class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :title
      t.string :url
      t.integer	:service_id
      t.timestamps
      t.boolean :haveInfo, :default => true
      t.integer :cogn, :default => 0
      t.integer :know, :default => 0
    end
  end
end
