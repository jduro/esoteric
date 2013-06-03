# NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
# DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
# USDL4EDU = RDF::Vocabulary.new NS
# FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
# RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"

# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)

# directory = "public/services/upload"
# path = File.join(directory, "nonio_LEI.ttl")
# graph = RDF::Graph.load(path, :format => :ttl)
# allPaths=Service.select(:path).map(&:path).uniq
# cogn=3
# know=1

# queryUSDL4EDCogn = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.CognitiveDimension,
#     RDFS.label => :label,
#     DC.description => :description,
#     USDL4EDU.hasValue => :value
#   }
# })
# queryUSDL4EDKnow = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.KnowledgeDimension,
#     RDFS.label => :label,
#     DC.description => :description,
#     USDL4EDU.hasValue => :value
#   }
# })

# queryOBCogn = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.OverallObjective,
#     USDL4EDU.hasCognitiveDimension => :cogn
#   }
# })
# queryOBKnow = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.OverallObjective,
#     USDL4EDU.hasKnowledgeDimension => :know
#   }
# })
# qUnit = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.CourseUnit,
#     USDL4EDU.hasTitle => :title,
#     USDL4EDU.hasOverallObjective => :obj
#   }
# })
# qOB = RDF::Query.new({
#   :q => {
#     RDF.type => USDL4EDU.CourseUnit,
#     USDL4EDU.hasOverallObjective => :obj
#   }
# })

# cognitiveDimension=Hash.new
# solutions=queryUSDL4EDCogn.execute(graphUSDL4EDU)
# solutions.each do |s|
# 	c=Hash.new
# 	c["label"]=s.label.to_s
# 	c["description"]=s.description.to_s
# 	c["value"]=s.value.to_i
# 	c["url"]=s.q
# 	cognitiveDimension[s.q]=c
# end
# knowledgeDimension=Hash.new
# solutions=queryUSDL4EDKnow.execute(graphUSDL4EDU)
# solutions.each do |s|
# 	c=Hash.new
# 	c["label"]=s.label.to_s
# 	c["description"]=s.description.to_s
# 	c["value"]=s.value.to_i
# 	c["url"]=s.q
# 	knowledgeDimension[s.q]=c
# end


# @sameOB=[]
# allPaths.each do |p|
# 	graphCompare = RDF::Graph.load(p, :format => :ttl)
# 	puts p
# 	puts "\n"

# 	qUnit.execute(graphCompare).each do |solution|
# 		aux=Hash.new
# 		aux["title"]=solution.title.to_s
# 		check=false
# 		if cogn
# 			solObjectiveCogn=queryOBCogn.execute(graphCompare)
# 			solObjectiveCogn.filter(:q => solution.obj).each do |s|
# 				# puts s.cogn.to_s,"/",cogn
# 				if cognitiveDimension[s.cogn]["value"]==cogn
# 					check=true
# 					aux["cogn"]=cogn
# 				end
# 			end
# 		end

# 		if know
# 			solObjectiveKnow=queryOBKnow.execute(graphCompare)
# 			solObjectiveKnow.filter(:q => solution.obj).each do |s|
# 				if knowledgeDimension[s.know]["value"]==know
# 					check=true
# 					aux[know]=know
# 				end
# 			end
# 		end

# 		if check
# 			@sameOB<<aux
# 		end
# 		check=false
# 	end

# end

# print @sameOB
class Hash
  def sorted_hash(&block)
    self.class[sort(&block)]   # Hash[ [[key1, value1], [key2, value2]] ]
  end
end



puts final