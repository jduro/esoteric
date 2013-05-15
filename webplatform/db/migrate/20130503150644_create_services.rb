class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :title
      t.string :url
      t.string :urlCourse
      t.string :path
      t.string :organization
      t.boolean :isCourse, :default => false
      t.timestamps
    end
  end
end
