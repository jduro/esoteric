class CreateServicehascontexts < ActiveRecord::Migration
  def change
    create_table :servicehascontexts, :id => false do |t|
   		t.references :service
   		t.references :educationalcontext
    end
    add_index :servicehascontexts, [:service_id, :educationalcontext_id], :name=>"index_servicehascontexts"
  end
end
