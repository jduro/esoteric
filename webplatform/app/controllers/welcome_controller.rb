class WelcomeController < ApplicationController
	NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
	DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
	SKOS=RDF::Vocabulary.new "http://www.w3.org/2004/02/skos/core#"
	FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
	RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"
	USDL4EDU = RDF::Vocabulary.new NS


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

		graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
		queryUSDL4EDULanguage = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Language,
		    RDFS.label => :label
		  }
		})
		queryUSDL4EDUDelivery = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.ModeDelivery,
		    RDFS.label => :label
		  }
		})
		queryUSDL4EDCogn = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CognitiveDimension,
		    RDFS.label => :label,
		    DC.description => :description,
		    USDL4EDU.hasValue => :value
		  }
		})
		queryUSDL4EDKnow = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.KnowledgeDimension,
		    RDFS.label => :label,
		    DC.description => :description,
		    USDL4EDU.hasValue => :value
		  }
		})

		cognitiveDimension=Hash.new
		solutions=queryUSDL4EDCogn.execute(graphUSDL4EDU)
		solutions.each do |s|
			c=Hash.new
			c["label"]=s.label.to_s
			c["description"]=s.description.to_s
			c["value"]=s.value.to_i
			cognitiveDimension[s.q]=c
		end
		knowledgeDimension=Hash.new
		solutions=queryUSDL4EDKnow.execute(graphUSDL4EDU)
		solutions.each do |s|
			c=Hash.new
			c["label"]=s.label.to_s
			c["description"]=s.description.to_s
			c["value"]=s.value.to_i
			knowledgeDimension[s.q]=c
		end



		graphContext = RDF::Graph.load("public/services/context.ttl", :format => :ttl)
		queryContext = RDF::Query.new({
		  :q => {
		    RDF.type => SKOS.Concept,
		    SKOS.prefLabel => :label
		  }
		})




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
		@unit["url"]=@serviceSelected.urlCourse
		solutionsUnit.filter(:q => itemServiceUnit).each do |solutionUnit|
				@unit["description"]=solutionUnit.description.to_s

				
				solutions=queryUSDL4EDUDelivery.execute(graphUSDL4EDU)
				solutions.filter(:q => solutionUnit.delivery).each do |solution|
					@unit["delivery"]=solution.label
				end
				

				solutions=queryUSDL4EDULanguage.execute(graphUSDL4EDU)
				solutions.filter(:q => solutionUnit.language).each do |solution|
					@unit["language"]=solution.label
				end
				# @unit["language"]=getLanguageName(solutionUnit.language)

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
			@unit["obj"]["cogn"]=cognitiveDimension[solution.cogn]
		end
		solutionsOBKnow.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["know"]=knowledgeDimension[solution.know]
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
				part["cogn"]=cognitiveDimension[solution.cogn]
			end
			solutionsObjectiveKnow.filter(:q => part["url"]).each do |solution|
				part["know"]=knowledgeDimension[solution.know]
			end
			solutionsObjectiveContext.filter(:q => part["url"]).each do |solution|
				context=Hash.new
				context["url"]=solution.context
				# context["label"]=solution.context

				solutions=queryContext.execute(graphContext)
				solutions.filter(:q => context["url"]).each do |solution|
					context["label"]= solution.label
				end

				# context["label"]=getContextName(context["url"])
				part["context"] << context
			end
			solutionsObjective=queryObjective.execute(graph)
			solutionsObjectiveKnow=queryObjectiveKnow.execute(graph)
			solutionsObjectiveCogn=queryObjectiveCogn.execute(graph)
			solutionsObjectiveContext=queryObjectiveContext.execute(graph)
		end
		@graphOverall = LazyHighCharts::HighChart.new('graph') do |f|
			f.options[:plotOptions]={
				:line => {:lineWidth => 0}
			}
			f.options[:chart]={
				:width => 500,
				:height => 200
			}
			f.options[:title][:text] = "Objectives"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/A", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 6
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/A", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
				:tickPositions => [0,1,2,3,4],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 4
			}
			tmp="Average"
			f.series(
			:name=> tmp, 
			:data=> [[@unit["obj"]["cogn"] ? @unit["obj"]["cogn"]["value"]: 0, @unit["obj"]["know"] ? @unit["obj"]["know"]["value"]: 0]],
			:marker => {:radius=>6}
			)
		end
		@aux=[@unit["cogn"] ? @unit["cogn"]["value"]: 0, @unit["know"] ? @unit["know"]["value"]: 0]


		@graphObjectives = LazyHighCharts::HighChart.new('graph') do |f|
			f.options[:plotOptions]={
				:line => {:lineWidth => 0}
			}
			f.options[:title][:text] = "Objectives Identified"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/A", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 6
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/A", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
				:tickPositions => [0,1,2,3,4],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 4
			}
			aux=1
			@unit["obj"]["parts"].each do |part|
				tmp="Objective #{aux}"
				f.series(
				:name=> tmp, 
				:data=> [[part["cogn"] ? part["cogn"]["value"]: 0, part["know"] ? part["know"]["value"]: 0]],
				:marker => {:radius=>6}
				)
				aux+=1
			end
			
	  	end




		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
	end

	# def getContextName(url)
	# 	solutions=queryContext.execute(graphContext)
	# 	solutions.filter(:q => url).each do |solution|
	# 		return solution.label
	# 	end
	# end

	# def getLanguageName(url)
	# 	solutions=queryUSDL4EDULanguage.execute(graphUSDL4EDU)
	# 	solutions.filter(:q => url).each do |solution|
	# 		return solution.label
	# 	end
	# end
end