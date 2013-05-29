class Educationalcontext < ActiveRecord::Base
	has_and_belongs_to_many :units, :join_table => "unithascontexts"
	has_and_belongs_to_many :services, :join_table => "servicehascontexts"
end
