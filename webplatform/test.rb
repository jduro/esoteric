NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS


service=Service.find(737)
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

queryService = RDF::Query.new({
  :q => {
    RDF.type => USDL4EDU.EducationalService,
    USDL4EDU.hasCourseUnit => :unit
  }
})

queryUnit = RDF::Query.new({
  :q => {
    RDF.type => USDL4EDU.CourseUnit
  }
})

# query.execute(graph).each do |solution|
# 	puts solution.q.to_s
# 	puts "name=#{solution.unit}"
# end

# solutionsService=queryService.execute(graph)
solutionsUnit=queryUnit.execute(graph)

solutionsUnit.each do |s|
	puts s.q.to_s
end
puts "----"
RDF::Query.new({q: {RDF.type => USDL4EDU.CourseUnit}}).execute(graph).each do |u|
	puts u.q.to_s
end




# solutionsService.filter(:q => service.url).each do |solution|
# 	puts solution.q.to_s
# 	puts "unit=#{solution.unit}"
# 	solutionsUnit.filter(:q2 => solution.unit).each do |solutionUnit|
# 		puts "\t description=#{solutionUnit.description}"
# 		# puts "\t delivery=#{solutionUnit.delivery}"
# 		# puts "\t language=#{solutionUnit.language}"
# 		# puts "\t hasOverallObjective=#{solutionUnit.obj}"
# 		# puts "\t teacher=#{solutionUnit.teacher}"
# 	end

# end



