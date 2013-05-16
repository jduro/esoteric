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


print "ola\n"
print @unitDB.url+"\n"

solutionsUnit=queryUnit.execute(graph)

solutionsUnit.filter(:q => @unitDB.url).each do |solutionUnit|
    @unit["description"]=solutionUnit.description.to_s
    print @unit["description"]
    @unit["ects"]=solutionUnit.ects
    @unit["semester"]=solutionUnit.semester

    # solutions=queryUSDL4EDUDelivery.execute(graphUSDL4EDU)
    # solutions.filter(:q => solutionUnit.delivery).each do |solution|
    #   @unit["delivery"]=solution.label
    # end
    

    # solutions=queryUSDL4EDULanguage.execute(graphUSDL4EDU)
    # solutions.filter(:q => solutionUnit.language).each do |solution|
    #   @unit["language"]=solution.label
    # end
    # @unit["language"]=getLanguageName(solutionUnit.language)

    obj=Hash.new
    obj["url"]=solutionUnit.obj
    @unit["obj"]=obj
    teacher=Hash.new
    teacher["url"]=solutionUnit.teacher
    print teacher["url"]+"\n"
    @unit["teachers"]=[]
    # solutionsTeacher.filter(:q => teacher["url"]).each do |s|
    #   teacher["name"]=s["first"].to_s+" "+s["last"].to_s
    #   print teacher["name"]
    # end

    @unit["teachers"] << teacher
end