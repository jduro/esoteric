class Service < ActiveRecord::Base
	has_many :units
	has_and_belongs_to_many :contexts, :join_table => "servicehascontexts"
end
