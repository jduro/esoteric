# NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
# DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
# USDL4EDU = RDF::Vocabulary.new NS
# FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
# RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"

# directory = "public/services/upload"
# path = File.join(directory, "nonio_LEI.ttl")
# graph = RDF::Graph.load(path, :format => :ttl)


a="107-108-109u-110u"
b=a.split("-")
ids=[]
idsU=[]
x=""


b.each do |sub|
    if sub.ends_with? "u"
        idsU<<sub[0..sub.size-2].to_i
        x+=sub+"-"
    else
        ids<<sub.to_i
    end
end
x=x[0..x.size-2]
y=ids.join("-")
z=x+"-"+y



puts b.delete_if{|n| n==109.to_s+"u"}

