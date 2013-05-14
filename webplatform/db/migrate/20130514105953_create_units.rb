class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :title
      t.string :url
      t.integer	:service_id
      t.timestamps
    end
  end
end
