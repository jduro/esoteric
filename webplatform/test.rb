NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
USDL4EDU = RDF::Vocabulary.new NS

directory = "public/services/upload"
path = File.join(directory, "nonio_MEI.ttl")
graph = RDF::Graph.load(path, :format => :ttl)

a=0
RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, DC.description => :description, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasURL => :urlCourse}}).execute(graph).each do |s|
	print "hello\n"
	a+=1
	service=Service.new
	# puts "URL:"+s.q.to_s
	service.url=s.q.to_s
	service.urlCourse=s.urlCourse.to_s
	if s.organization==USDL4EDU.edx
		service.organization="edx"
	elsif s.organization==USDL4EDU.coursera
		service.organization="coursera"
	elsif s.organization==USDL4EDU.udacity
		service.organization="udacity"
	elsif description=="http://rdf.genssiz.dei.uc.pt/usdl4edu#dei-uc"
		service.organization="dei"
	end
	print service.organization
	service.title=s.description.to_s.gsub(/ - .*/,"")
	# puts "title:"+service.title
	# puts "description:"+service.description
	service.path=path
	# service.save
end
puts "SUM"+a.to_s


