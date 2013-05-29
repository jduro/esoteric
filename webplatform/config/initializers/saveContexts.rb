NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
SKOS=RDF::Vocabulary.new "http://www.w3.org/2004/02/skos/core#"
FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"
USDL4EDU = RDF::Vocabulary.new NS

GRAPHCONTEXT = RDF::Graph.load("public/services/context.ttl", :format => :ttl)
queryContext = RDF::Query.new({
  :q => {
    RDF.type => SKOS.Concept,
    SKOS.prefLabel => :label
  }
})
queryContext.execute(GRAPHCONTEXT).each do |s|
    if not Educationalcontext.exists?(:url=>s.q.to_s)
        c=Educationalcontext.new
        c.title=s.label.to_s
        c.url=s.q.to_s
        c.save
    end
end