NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS
FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"


service=Service.find(793)
puts service.path

# directory = "public/services/upload"
# path = File.join(directory, "edx.ttl")
# graph = RDF::Graph.load(service.path, :format => :ttl)


require 'rubygems'
require 'google_chart'

# Pie Chart
GoogleChart::PieChart.new('320x200', "Pie Chart",false) do |pc|
  pc.data "Apples", 40
  pc.data "Banana", 20
  pc.data "Peach", 30
  pc.data "Orange", 60
  puts "\nPie Chart"
  puts pc.to_url
  
  # Pie Chart with no labels
  pc.show_labels = false
  puts "\nPie Chart (with no labels)"
  puts pc.to_url  
end


