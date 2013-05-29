class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :title
      t.string :url
      t.string :urlCourse
      t.string :path
      t.string :organization
      t.boolean :isCourse, :default => false
      t.boolean :haveInfo, :default => true
      t.integer :cogn, :default => 0
      t.integer :know, :default => 0
      t.timestamps
    end
  end
end
