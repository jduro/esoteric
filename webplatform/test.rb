NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS
FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"


service=Service.find(793)
puts service.path

directory = "public/services/upload"
path = File.join(directory, "edx.ttl")
graph = RDF::Graph.load(service.path, :format => :ttl)
# puts graph.size
# RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, USDL4EDU.hasCourseUnit => :unit}}).execute(graph).each do |s|
# 	if s.q.to_s==service.url
# 		puts s.q.to_s
# 		# puts s.degree.to_s
# 		puts s.unit.to_s

# 		RDF::Query.new({q: {RDF.type => USDL4EDU.CourseUnit, DC.description => :description, USDL4EDU.hasDeliveryMode => :delivery, USDL4EDU.hasLanguage => :language, USDL4EDU.hasOverallObjective => :objective}}).execute(graph).each do |u|
# 			if u.q.to_s==s.unit
# 				puts "\n\t"+u.description.to_s
# 				puts "\n\t"+u.delivery.to_s
# 				puts "\n\t"+u.language.to_s

# 				RDF::Query.new({q: {RDF.type => USDL4EDU.OverallObjective, DC.description => :description, USDL4EDU.hasPartObjective => :part, USDL4EDU.hasCognitiveDimension => :cognitive}}).execute(graph).each do |ob|
# 					if ob.q.to_s==u.objective
# 						puts "\n\t\t"+ob.description.to_s
# 						puts "\n\t\t"+ob.part.to_s
# 						puts "\n\t\t"+ob.cognitive.to_s
# 					end
# 				end

# 			end

# 		end

# 	end
# end
puts "-----"

queryTeacher = RDF::Query.new({
  :q => {
    RDF.type => FOAF.Person,
    FOAF.firstName => :first, 
    FOAF.lastName => :last
  }
})
solutionsTeacher=queryTeacher.execute(graph)
solutionsTeacher.filter(:q => "http://rdf.genssiz.dei.uc.pt/usdl4edu#Peter-Norvig").each do |s|
	puts s["first"]
end


