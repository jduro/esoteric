NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS
FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"

directory = "public/services/upload"
path = File.join(directory, "nonio_MEI.ttl")
graph = RDF::Graph.load(path, :format => :ttl)


queryServiceDegree = RDF::Query.new({
  :q => {
    RDF.type => USDL4EDU.EducationalService,
    DC.description => :description,
    USDL4EDU.hasOrganization => :organization, 
    USDL4EDU.hasURL => :urlCourse,
    USDL4EDU.hasDegree => :degree,
  }
})
queryDegree = RDF::Query.new({
  :q => {
    RDF.type => USDL4EDU.Degree,
    USDL4EDU.hasCourseUnit => :unit,
  }
})
queryUnit = RDF::Query.new({
  :q => {
    RDF.type => USDL4EDU.CourseUnit,
    USDL4EDU.hasTitle => :title
  }
})

solutions=queryServiceDegree.execute(graph)
solutionsD=queryDegree.execute(graph)
solutionsU=queryUnit.execute(graph)
if solutions.size>0
	solutions.each do |s|
		print s.q.to_s+"\n"
		solutionsD.filter(:q => s.degree).each do |s1|

			solutionsU.filter(:q => s1.unit).each do |s2|
				print s2.q.to_s+"\n"
				print s2.title.to_s+"\n"
			end
			solutionsU=queryUnit.execute(graph)
		end
	end
end

