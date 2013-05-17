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
        USDL4EDU.hasTeacher => :teacher,
        USDL4EDU.hasEcts => :ects,
        USDL4EDU.hasSemester => :semester
      }
    })

@unitDB=Unit.find(103)
@unit=Hash.new


@a=[[13, 0, 0, 0, 0], [0, 0, 0, 0, 0], [2, 0, 0, 0, 0], [6, 0, 0, 0, 0], [6, 1, 2, 0, 0], [0, 1, 1, 0, 0], [1, 0, 0, 0, 0]] 
print @a.size
print @a[0].size
for i in 0..(@a.size-1)
    for j in 0..(@a[i].size-1)
        puts i.to_s+","+j.to_s+"\n"
    end
end

# @data=[]
# for i in 0..@a.size
#     for j in 0..@a[i].size
#         if @a[i][j]!=0
#             print i+","
#             print j
#             print "\n"
#             aux=[]
#             aux=[i,j,@a[i][j]]
#             @data << aux
#         end
#     end
# end