class Service < ActiveRecord::Base
	has_many :units
	has_and_belongs_to_many :educationalcontexts, :join_table => :servicehascontexts
end
