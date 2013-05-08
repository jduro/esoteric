class WelcomeController < ApplicationController
	NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
	DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
	SKOS=RDF::Vocabulary.new "http://www.w3.org/2004/02/skos/core#"
	FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
	USDL4EDU = RDF::Vocabulary.new NS

	# graphContext = RDF::Graph.load("public/services/context.ttl", :format => :ttl)

	# queryContext = RDF::Query.new({
	#   :q => {
	#     RDF.type => SKOS.Concept,
	#     SKOS.prefLabel => :label
	#   }
	# })

	def index()
		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
	end

	def import()
		begin
			name = params[:file].original_filename
		    directory = "public/services/upload"
		    path = File.join(directory, name)

		    if File.exist?(path)
		    	raise "File already exists"
		    end


		    File.open(path, "wb") { |f| f.write(params[:file].read) }

			graph = RDF::Graph.load(path, :format => :ttl)

			puts "----BEGIN----"
			check=false
			RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, DC.description => :description, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasURL => :urlCourse}}).execute(graph).each do |s|
				check=true
				service=Service.new
				# puts "URL:"+s.q.to_s
				service.url=s.q.to_s
				service.urlCourse=s.urlCourse.to_s
				if s.organization==USDL4EDU.edx
					service.organization="Edx"
				elsif s.organization==USDL4EDU.coursera
					service.organization="Coursera"
				elsif s.organization==USDL4EDU.udacity
					service.organization="Udacity"
				elsif s.organization=="http://rdf.genssiz.dei.uc.pt/usdl4edu#dei-uc"
					service.organization="DEI-UC"
				end
				service.title=s.description.to_s.gsub(/ - .*/,"")
				# puts "title:"+service.title
				# puts "description:"+service.description
				service.path=path
				service.save
			end
			if check==false
				File.delete(path)
				raise "File is not a usdl4edu instance"
			end
			puts "----END----"
			flash[:notice] = "File uploaded successfully!"
			redirect_to action: "index"
		rescue Exception => exc
			flash[:error] = "Error: "+exc.message
			redirect_to action: "index"
		end
	end

	def info()
		@serviceSelected = Service.find(params[:id])
		
		graph = RDF::Graph.load(@serviceSelected.path, :format => :ttl)
		

		queryService = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.EducationalService,
		    USDL4EDU.hasCourseUnit => :unit
		  }
		})
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
		queryOB = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallObjective,
		    DC.description => :description
		  }
		})
		queryOBCogn = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallObjective,
		    USDL4EDU.hasCognitiveDimension => :cogn
		  }
		})
		queryOBKnow = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallObjective,
		    USDL4EDU.hasKnowledgeDimension => :know
		  }
		})
		queryOBParts = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallObjective,
		    USDL4EDU.hasPartObjective => :part
		  }
		})
		queryTeacher = RDF::Query.new({
		  :q => {
		    RDF.type => FOAF.Person,
		    FOAF.firstName => :first, 
		    FOAF.lastName => :last
		  }
		})
		queryObjective = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Objective,
		    DC.description => :description
		  }
		})
		queryObjectiveCogn = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Objective,
		    USDL4EDU.hasCognitiveDimension => :cogn
		  }
		})
		queryObjectiveKnow = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Objective,
		    USDL4EDU.hasKnowledgeDimension => :know
		  }
		})
		queryObjectiveContext = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Objective,
		    USDL4EDU.hasContext => :context
		  }
		})

		solutionsService=queryService.execute(graph)
		solutionsUnit=queryUnit.execute(graph)
		solutionsTeacher=queryTeacher.execute(graph)
		solutionsOB=queryOB.execute(graph)
		solutionsOBKnow=queryOBKnow.execute(graph)
		solutionsOBCogn=queryOBCogn.execute(graph)
		solutionsOBParts=queryOBParts.execute(graph)
		solutionsObjective=queryObjective.execute(graph)
		solutionsObjectiveCogn=queryObjectiveCogn.execute(graph)
		solutionsObjectiveKnow=queryObjectiveKnow.execute(graph)
		solutionsObjectiveContext=queryObjectiveContext.execute(graph)
		
		itemServiceUnit=""
		solutionsService.filter(:q => @serviceSelected.url).each do |solution|
			puts solution.q.to_s
			puts "unit=#{solution.unit}"
			itemServiceUnit=solution.unit
		end

		@unit = Hash.new
		@unit["teachers"]=[]
		solutionsUnit.filter(:q => itemServiceUnit).each do |solutionUnit|
				@unit["description"]=solutionUnit.description.to_s
				@unit["delivery"]=solutionUnit.delivery
				@unit["language"]=solutionUnit.language
				obj=Hash.new
				obj["url"]=solutionUnit.obj
				@unit["obj"]=obj
				teacher=Hash.new
				teacher["url"]=solutionUnit.teacher

				solutionsTeacher.filter(:q => teacher["url"]).each do |s|
					teacher["name"]=s["first"].to_s+" "+s["last"].to_s
				end

				@unit["teachers"] << teacher
		end
		solutionsOB.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["description"]=solution.description.to_s
		end
		solutionsOBCogn.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["cogn"]=solution.cogn
		end
		solutionsOBKnow.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["know"]=solution.know
		end
		@unit["obj"]["parts"]=[]
		solutionsOBParts.filter(:q => @unit["obj"]["url"]).each do |solution|
			part=Hash.new
			part["url"]=solution.part
			part["context"]=[]
			@unit["obj"]["parts"] << part
		end

		@unit["obj"]["parts"].each do |part|
			solutionsObjective.filter(:q => part["url"]).each do |solution|
				part["description"]=solution.description.to_s
			end
			solutionsObjectiveCogn.filter(:q => part["url"]).each do |solution|
				part["cogn"]=solution.cogn
			end
			solutionsObjectiveKnow.filter(:q => part["url"]).each do |solution|
				part["know"]=solution.know
			end
			solutionsObjectiveContext.filter(:q => part["url"]).each do |solution|
				context=Hash.new
				context["url"]=solution.context
				context["label"]=solution.context
				# context["label"]=getContextName(context["url"])
				part["context"] << context
			end
			solutionsObjective=queryObjective.execute(graph)
			solutionsObjectiveKnow=queryObjectiveKnow.execute(graph)
			solutionsObjectiveCogn=queryObjectiveCogn.execute(graph)
			solutionsObjectiveContext=queryObjectiveContext.execute(graph)
		end


		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
	end

	def getContextName(url)
		solutions=queryContext.execute(graphContext)
		solutionsObjectiveContext.filter(:q => url).each do |solution|
			return solution.label
		end
	end
end