class CreateUnithascontexts < ActiveRecord::Migration
  def change
    create_table :unithascontexts do |t|
    	t.integer :unit_id
   		t.integer :educationalcontexts_id
      	t.timestamps
    end

    add_index :unithascontexts, [:unit_id, :educationalcontexts_id], :name=>"index_unithascontexts"
  end
end
