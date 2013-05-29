class CreateEducationalcontexts < ActiveRecord::Migration
  def change
    create_table :educationalcontexts do |t|
      t.string :title
      t.string :url
      t.timestamps
    end
  end
end
