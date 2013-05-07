class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :title
      t.string :url
      t.string :urlCourse
      t.string :path
      t.string :organization	
      t.timestamps
    end
  end
end
