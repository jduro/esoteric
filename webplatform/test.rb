NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS
FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"

directory = "public/services/upload"
path = File.join(directory, "nonio_LEI.ttl")
graph = RDF::Graph.load(path, :format => :ttl)


queryUnit = RDF::Query.new({
    :q => {
      RDF.type => USDL4EDU.CourseUnit,
      DC.description => :description, 
      USDL4EDU.hasDeliveryMode => :delivery, 
      USDL4EDU.hasLanguage => :language, 
      USDL4EDU.hasOverallObjective => :obj,
      USDL4EDU.hasTeacher => :teacher
    }
  })

solutionsUnit=queryUnit.execute(graph)