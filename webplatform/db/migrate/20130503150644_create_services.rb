class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :title
      t.string :url
      t.string :path
      t.string :description	
      t.timestamps
    end
  end
end
