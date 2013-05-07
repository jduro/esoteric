NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS


service=Service.find(312)

directory = "public/services/upload"
path = File.join(directory, "edx.ttl")
graph = RDF::Graph.load(service.path, :format => :ttl)
puts graph.size
RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, USDL4EDU.hasCourseUnit => :unit}}).execute(graph).each do |s|
	puts s.q.to_s
	if s.q.to_s==service.url
		puts s.q.to_s
		# puts s.degree.to_s
		puts s.unit.to_s
	end
end



