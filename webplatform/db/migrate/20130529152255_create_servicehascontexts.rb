class CreateServicehascontexts < ActiveRecord::Migration
  def change
    create_table :servicehascontexts do |t|
   		t.integer :service_id
   		t.integer :educationalcontexts_id
      	t.timestamps
    end
    add_index :servicehascontexts, [:service_id, :educationalcontexts_id], :name=>"index_servicehascontexts"
  end
end
