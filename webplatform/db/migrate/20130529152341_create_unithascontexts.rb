class CreateUnithascontexts < ActiveRecord::Migration
  def change
    create_table :unithascontexts, :id => false do |t|
   		t.references :unit
   		t.references :educationalcontext
    end

    add_index :unithascontexts, [:unit_id, :educationalcontext_id], :name=>"index_unithascontexts"
  end
end
