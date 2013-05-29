class Unit < ActiveRecord::Base
	belongs_to :service
	has_and_belongs_to_many :educationalcontexts, :join_table => "unithascontexts"
end
