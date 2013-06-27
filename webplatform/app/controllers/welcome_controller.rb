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

	def blank()
		@isIndex=true
		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
		flash[:notice]="Exited from view section."
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
			# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
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

			# cognitiveDimension=Hash.new
			# solutions=queryUSDL4EDCogn.execute(Webplatform::Application::GRAPHUSDL4EDU)
			# solutions.each do |s|
			# 	c=Hash.new
			# 	c["label"]=s.label.to_s
			# 	c["description"]=s.description.to_s
			# 	c["value"]=s.value.to_i
			# 	cognitiveDimension[s.q]=c
			# end
			# knowledgeDimension=Hash.new
			# solutions=queryUSDL4EDKnow.execute(Webplatform::Application::GRAPHUSDL4EDU)
			# solutions.each do |s|
			# 	c=Hash.new
			# 	c["label"]=s.label.to_s
			# 	c["description"]=s.description.to_s
			# 	c["value"]=s.value.to_i
			# 	knowledgeDimension[s.q]=c
			# end

			queryServiceDegree = RDF::Query.new({
			  :q => {
			    RDF.type => USDL4EDU.EducationalService,
			    DC.description => :description,
			    USDL4EDU.hasOrganization => :organization, 
			    USDL4EDU.hasURL => :urlCourse,
			    USDL4EDU.hasDegree => :degree,
			  }
			})
			queryDegree = RDF::Query.new({
			  :q => {
			    RDF.type => USDL4EDU.Degree,
			    USDL4EDU.hasCourseUnit => :unit,
			  }
			})
			queryUnit = RDF::Query.new({
			  :q => {
			    RDF.type => USDL4EDU.CourseUnit,
			    USDL4EDU.hasTitle => :title,
			    USDL4EDU.hasOverallObjective => :obj
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
			queryObjectiveContext = RDF::Query.new({
			  :q => {
			    RDF.type => USDL4EDU.Objective,
			    USDL4EDU.hasContext => :context
			  }
			})

			solutions=queryServiceDegree.execute(graph)
			solutionsD=queryDegree.execute(graph)
			solutionsU=queryUnit.execute(graph)
			if solutions.size>0
				solutions.each do |s|
					service=Service.new
					service.url=s.q.to_s
					service.urlCourse=s.urlCourse.to_s
					service.title=s.description.to_s.gsub(/ - .*/,"")
					service.isCourse=true
					if s.organization==USDL4EDU.edx
						service.organization="Edx"
					elsif s.organization==USDL4EDU.coursera
						service.organization="Coursera"
					elsif s.organization==USDL4EDU.udacity
						service.organization="Udacity"
					elsif s.organization=="http://rdf.genssiz.dei.uc.pt/usdl4edu#dei-uc"
						service.organization="DEI-UC"
					end
					sC=0
					sK=0
					cC=0
					cK=0
					solutionsD.filter(:q => s.degree).each do |s1|
						solutionsU.filter(:q => s1.unit).each do |s2|
							unit=Unit.new
							unit.url=s2.q.to_s
							unit.title=s2.title.to_s


							solutionsOBKnow=queryOBKnow.execute(graph)
							solutionsOBCogn=queryOBCogn.execute(graph)
							cogn=0
							know=0
							solutionsOBCogn.filter(:q => s2.obj).each do |solutionOB|
								cogn=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
								sC+=cogn
								cC+=1
							end
							solutionsOBKnow.filter(:q => s2.obj).each do |solutionOB|
								know=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
								sK+=know
								cK+=1
							end
							unit.cogn=cogn
							unit.know=know

							solutionOBPart=queryOBParts.execute(graph)
							solutionOBPart.filter(:q => s2.obj).each do |solutionP|
								solutionContext=queryObjectiveContext.execute(graph)
								solutionContext.filter(:q=>solutionP.part).each do |solutionC|
									edu=Educationalcontext.find_by_url(solutionC.context.to_s)
									if edu
										if not unit.educationalcontexts.include?(edu)
											unit.educationalcontexts << edu
										end
									end
								end
							end

							if cogn==0 and know==0
								unit.haveInfo=false
							end
							unit.save
							service.units << unit
						end
						solutionsU=queryUnit.execute(graph)
					end
					service.cogn= cC==0 ? 0 : (sC/cC).round()
					service.know= cK==0 ? 0 : (sK/cK).round()

					service.path=path
					service.save
				end
			else
				puts "----BEGIN----"
				check=false
				RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, DC.description => :description, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasURL => :urlCourse, USDL4EDU.hasCourseUnit=>:unit}}).execute(graph).each do |s|
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
					# service.title=s.description.to_s.gsub(/ - .*/,"")

					solutionsU=queryUnit.execute(graph)
					solutionsU.filter(:q => s.unit).each do |s2|
						service.title=s2.title.to_s
						solutionsOBKnow=queryOBKnow.execute(graph)
						solutionsOBCogn=queryOBCogn.execute(graph)
						cogn=0
						know=0
						solutionsOBCogn.filter(:q => s2.obj).each do |solutionOB|
							cogn=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
						end
						solutionsOBKnow.filter(:q => s2.obj).each do |solutionOB|
							know=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
						end
						solutionOBPart=queryOBParts.execute(graph)
						solutionOBPart.filter(:q => s2.obj).each do |solutionP|
							solutionContext=queryObjectiveContext.execute(graph)
							solutionContext.filter(:q=>solutionP.part).each do |solutionC|
								edu=Educationalcontext.find_by_url(solutionC.context.to_s)
								if edu
									if not service.educationalcontexts.include?(edu)
										service.educationalcontexts << edu
									end
								end
							end
						end
						service.cogn=cogn
						service.know=know

						if cogn==0 and know==0
							service.haveInfo=false
						end
					end
					service.path=path
					puts "Service "+service.title+" has been save\n"
					service.save
				end
				if check==false
					File.delete(path)
					raise "File is not a usdl4edu instance"
				end
			end
			puts "----END----"
			flash[:notice] = "File uploaded successfully!"
			redirect_to action: "index"
		rescue Exception => exc
			flash[:error] = "Error: "+exc.message
			# logger.error "#{ exc.message } - (#{ exc.class })" << "\n" << (exc.backtrace or []).join("\n")
			redirect_to action: "index"
		end
	end

	def info()

		allPaths=Service.select(:path).map(&:path).uniq

		@serviceSelected = Service.find(params[:id])
		
		graph = RDF::Graph.load(@serviceSelected.path, :format => :ttl)

		# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
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

		# cognitiveDimension=Hash.new
		# solutions=queryUSDL4EDCogn.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	c["url"]=s.q
		# 	cognitiveDimension[s.q]=c
		# end
		# knowledgeDimension=Hash.new
		# solutions=queryUSDL4EDKnow.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	c["url"]=s.q
		# 	knowledgeDimension[s.q]=c
		# end



		# graphContext = RDF::Graph.load("public/services/context.ttl", :format => :ttl)
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
		queryDegree = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
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
		queryUnitOP = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    USDL4EDU.hasOverallPrerequisite => :pre
		  }
		})
		queryOP = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallPrerequisite,
		    DC.description => :description
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
		solutionsDegree=queryDegree.execute(graph)
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

		solutionsOP=queryOP.execute(graph)
		solutionsUnitOP=queryUnitOP.execute(graph)
		
		itemServiceUnit=""
		checkCourse=false
		solutionsService.filter(:q => @serviceSelected.url).each do |solution|
			checkCourse=true
			itemServiceUnit=solution.unit
		end


		@unit = Hash.new
		@unit["teachers"]=[]
		@unit["url"]=@serviceSelected.urlCourse
		solutionsUnit.filter(:q => itemServiceUnit).each do |solutionUnit|
				@unit["description"]=solutionUnit.description.to_s

				
				solutions=queryUSDL4EDUDelivery.execute(Webplatform::Application::GRAPHUSDL4EDU)
				solutions.filter(:q => solutionUnit.delivery).each do |solution|
					@unit["delivery"]=solution.label
				end
				

				solutions=queryUSDL4EDULanguage.execute(Webplatform::Application::GRAPHUSDL4EDU)
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

		solutionsUnitOP.filter(:q => itemServiceUnit).each do |solution|
			pre=Hash.new
			pre["url"]=solution.pre
			@unit["pre"]=pre
		end
		if @unit["pre"]
			solutionsOP.filter(:q => @unit["pre"]["url"]).each do |solution|
				@unit["pre"]["description"]=solution.description.to_s
			end
		end

		solutionsOB.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["description"]=solution.description.to_s
		end
		solutionsOBCogn.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solution.cogn]
		end
		solutionsOBKnow.filter(:q => @unit["obj"]["url"]).each do |solution|
			@unit["obj"]["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solution.know]
		end



		# @sameOB=[]
		# allPaths.each do |p|
		# 	graphCompare = RDF::Graph.load(p, :format => :ttl)
		# 	qUnit = RDF::Query.new({
		# 	  :q => {
		# 	    RDF.type => USDL4EDU.CourseUnit,
		# 	    USDL4EDU.hasTitle => :title,
		# 	    USDL4EDU.hasOverallObjective => :obj
		# 	  }
		# 	})
		# 	qOB = RDF::Query.new({
		# 	  :q => {
		# 	    RDF.type => USDL4EDU.CourseUnit,
		# 	    USDL4EDU.hasOverallObjective => :obj
		# 	  }
		# 	})

		# 	solUnit=qUnit.execute(graphCompare)
		# 	solUnit.each do |solution|
		# 		aux=Hash.new
		# 		aux["title"]=solution.title.to_s
		# 		check=false
		# 		check2=false
		# 		if @unit["obj"]["cogn"]
		# 			solObjectiveCogn=queryOBCogn.execute(graphCompare)
		# 			solObjectiveCogn.filter(:q => solution.obj).each do |s|
		# 				if s.cogn==@unit["obj"]["cogn"]["url"]
		# 					check=true
		# 					aux["cogn"]=@unit["obj"]["cogn"]["value"]
		# 				end
		# 			end
		# 		end

		# 		if @unit["obj"]["know"]
		# 			solObjectiveKnow=queryOBKnow.execute(graphCompare)
		# 			solObjectiveKnow.filter(:q => solution.obj).each do |s|
		# 				if s.know==@unit["obj"]["know"]["url"]
		# 					check2=true
		# 					aux["know"]=@unit["obj"]["know"]["value"]
		# 				end
		# 			end
		# 		end



		# 		if check and check2
		# 			@sameOB<<aux
		# 		end

		# 	end

		# end
		contextSelected=[]

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
				part["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solution.cogn]
			end
			solutionsObjectiveKnow.filter(:q => part["url"]).each do |solution|
				part["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solution.know]
			end
			solutionsObjectiveContext.filter(:q => part["url"]).each do |solution|
				context=Hash.new
				context["url"]=solution.context.to_s
				# context["label"]=solution.context
				context["label"]=Educationalcontext.find_by_url(context["url"]).title
				# solutions=queryContext.execute(Webplatform::Application::GRAPHCONTEXT)
				# solutions.filter(:q => context["url"]).each do |solution|
				# 	context["label"]= solution.label
				# end

				# context["label"]=getContextName(context["url"])
				part["context"] << context

			end
			solutionsObjective=queryObjective.execute(graph)
			solutionsObjectiveKnow=queryObjectiveKnow.execute(graph)
			solutionsObjectiveCogn=queryObjectiveCogn.execute(graph)
			solutionsObjectiveContext=queryObjectiveContext.execute(graph)
		end


		if @unit["obj"]["cogn"]
			@sameOB=Service.where(:cogn => @unit["obj"]["cogn"]["value"])
			@sameOBU=Unit.where(:cogn => @unit["obj"]["cogn"]["value"])
		else
			@sameOB=Service.where(:cogn => 0)
			@sameOBU=Unit.where(:cogn => 0)
		end

		if @unit["obj"]["know"]
			@sameOB=@sameOB.where(:know => [@unit["obj"]["know"]["value"]])
			@sameOBU=@sameOBU.where(:know => [@unit["obj"]["know"]["value"]])
		else
			@sameOB=@sameOB.where(:know => 0)
			@sameOBU=@sameOBU.where(:know => 0)
		end
		@sameContext=[]
		@sameOB.delete_if{|x| x == @serviceSelected}

		@sameOB=@sameOB+@sameOBU
		contexts=@serviceSelected.educationalcontexts
		
		@sameOB.each do |s|
			aux=Hash.new
			aux["s"]=s
			aux["tooltip"]=""
			aux["cogn"]=Webplatform::Application::COGNITIVEDIMENSION.values.select{|f| f["value"]==s.cogn}.first
			aux["know"]=Webplatform::Application::KNOWLEDGEDIMENSION.values.select{|f| f["value"]==s.know}.first
			count=0
			s.educationalcontexts.each do |edu|
				if contexts.include?edu
					count+=1
					if not aux["tooltip"].include? edu.title
						aux["tooltip"]+=edu.title+"<br>"
					end
				end
			end
			if count>0 and s!=@serviceSelected
				aux["n"]=count
				@sameContext<<aux
			end
		end

		@sameContext=@sameContext.sort_by { |hsh| -hsh["n"] }
		@sameContext=@sameContext[0..10]

		@graphOverall = LazyHighCharts::HighChart.new('graph') do |f|
			f.options[:plotOptions]={
				:line => {:lineWidth => 0}
			}
			f.options[:chart]={
				:width => 500,
				:height => 200
			}
			f.options[:title][:text] = "Average of Curricular objectives according to Bloom's Taxonomy"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 6,
				:min => 0
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
				:tickPositions => [0,1,2,3,4],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 4,
				:min => 0
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
			f.options[:title][:text] = "Objectives Identified according to Bloom's Taxonomy"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 6,
				:min => 0
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
				:tickPositions => [0,1,2,3,4],
				:gridLineWidth => '1',
				:lineWidth => 1,
        		:tickmarkPlacement => 'on',
				:max => 4,
				:min => 0
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


	def infounit()
		@unitDB = Unit.find(params[:id])
		@serviceSelected=@unitDB.service

		graph = RDF::Graph.load(@serviceSelected.path, :format => :ttl)

		# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
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

		# cognitiveDimension=Hash.new
		# solutions=queryUSDL4EDCogn.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	cognitiveDimension[s.q]=c
		# end
		# knowledgeDimension=Hash.new
		# solutions=queryUSDL4EDKnow.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	knowledgeDimension[s.q]=c
		# end



		# graphContext = RDF::Graph.load("public/services/context.ttl", :format => :ttl)
		queryContext = RDF::Query.new({
		  :q => {
		    RDF.type => SKOS.Concept,
		    SKOS.prefLabel => :label
		  }
		})




		
		queryDegree = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
		    USDL4EDU.hasCourseUnit => :unit
		  }
		})
		queryUnit = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    DC.description => :description, 
		    USDL4EDU.hasDeliveryMode => :delivery, 
		    USDL4EDU.hasLanguage => :language, 
		    USDL4EDU.hasTeacher => :teacher,
		    USDL4EDU.hasEcts => :ects,
		    USDL4EDU.hasSemester => :semester
		  }
		})
		queryUnitOP = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    USDL4EDU.hasOverallPrerequisite => :pre
		  }
		})
		queryUnitOB = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    USDL4EDU.hasOverallObjective => :obj
		  }
		})
		queryOB = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallObjective,
		    DC.description => :description
		  }
		})
		queryOP = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.OverallPrerequisite,
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

		solutionsDegree=queryDegree.execute(graph)
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
		solutionsOP=queryOP.execute(graph)
		solutionsUnitOP=queryUnitOP.execute(graph)
		solutionsUnitOB=queryUnitOB.execute(graph)
		
		


		@unit = Hash.new
		@unit["teachers"]=[]
		@unit["url"]=@serviceSelected.urlCourse
		solutionsUnit.filter(:q => @unitDB.url).each do |solutionUnit|
			@unit["description"]=solutionUnit.description.to_s

			@unit["ects"]=solutionUnit.ects
			@unit["semester"]=solutionUnit.semester

			solutions=queryUSDL4EDUDelivery.execute(Webplatform::Application::GRAPHUSDL4EDU)
			solutions.filter(:q => solutionUnit.delivery).each do |solution|
				@unit["delivery"]=solution.label
			end
			

			solutions=queryUSDL4EDULanguage.execute(Webplatform::Application::GRAPHUSDL4EDU)
			solutions.filter(:q => solutionUnit.language).each do |solution|
				@unit["language"]=solution.label
			end
			# @unit["language"]=getLanguageName(solutionUnit.language)

			teacher=Hash.new
			teacher["url"]=solutionUnit.teacher

			solutionsTeacher.filter(:q => teacher["url"]).each do |s|
				teacher["name"]=s["first"].to_s+" "+s["last"].to_s
			end

			@unit["teachers"] << teacher
		end
		solutionsUnitOP.filter(:q => @unitDB.url).each do |solution|
			pre=Hash.new
			pre["url"]=solution.pre
			@unit["pre"]=pre
		end
		if @unit["pre"]
			solutionsOP.filter(:q => @unit["pre"]["url"]).each do |solution|
				@unit["pre"]["description"]=solution.description.to_s
			end
		end

		solutionsUnitOB.filter(:q => @unitDB.url).each do |solution|
			obj=Hash.new
			obj["url"]=solution.obj
			@unit["obj"]=obj
		end
		if @unit["obj"]
			solutionsOP.filter(:q => @unit["obj"]["url"]).each do |solution|
				@unit["obj"]["description"]=solution.description.to_s
			end

			solutionsOB.filter(:q => @unit["obj"]["url"]).each do |solution|
				@unit["obj"]["description"]=solution.description.to_s
			end
			solutionsOBCogn.filter(:q => @unit["obj"]["url"]).each do |solution|
				@unit["obj"]["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solution.cogn]
			end
			solutionsOBKnow.filter(:q => @unit["obj"]["url"]).each do |solution|
				@unit["obj"]["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solution.know]
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
					part["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solution.cogn]
				end
				solutionsObjectiveKnow.filter(:q => part["url"]).each do |solution|
					part["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solution.know]
				end
				solutionsObjectiveContext.filter(:q => part["url"]).each do |solution|
					context=Hash.new
					context["url"]=solution.context.to_s
					# context["label"]=solution.context

					# solutions=queryContext.execute(Webplatform::Application::GRAPHCONTEXT)
					# solutions.filter(:q => context["url"]).each do |solution|
					# 	context["label"]= solution.label
					# end
					context["label"]=Educationalcontext.find_by_url(context["url"]).title

					# context["label"]=getContextName(context["url"])
					part["context"] << context
				end
				solutionsObjective=queryObjective.execute(graph)
				solutionsObjectiveKnow=queryObjectiveKnow.execute(graph)
				solutionsObjectiveCogn=queryObjectiveCogn.execute(graph)
				solutionsObjectiveContext=queryObjectiveContext.execute(graph)
			end

			@sameOB=[]
			if @unit["obj"]["cogn"]
				@sameOB=Service.where(:cogn => @unit["obj"]["cogn"]["value"])
				@sameOBU=Unit.where(:cogn => @unit["obj"]["cogn"]["value"])
			else
				@sameOB=Service.where(:cogn => 0)
				@sameOBU=Unit.where(:cogn => 0)
			end
			
			if @unit["obj"]["know"]
				@sameOB=@sameOB.where(:know => [@unit["obj"]["know"]["value"]])
				@sameOBU=@sameOBU.where(:know => [@unit["obj"]["know"]["value"]])
			else
				@sameOB=@sameOB.where(:know => 0)
				@sameOBU=@sameOBU.where(:know => 0)
			end
			@sameContext=[]
			@sameOBU.delete_if{|x| x == @unitDB}

			@sameOB=@sameOB+@sameOBU
			contexts=@unitDB.educationalcontexts
			@sameOB.each do |s|
				aux=Hash.new
				aux["s"]=s
				aux["tooltip"]=""
				aux["cogn"]=Webplatform::Application::COGNITIVEDIMENSION.values.select{|f| f["value"]==s.cogn}.first
				aux["know"]=Webplatform::Application::KNOWLEDGEDIMENSION.values.select{|f| f["value"]==s.know}.first
				count=0
				s.educationalcontexts.each do |edu|
					if contexts.include?edu
						count+=1
						if not aux["tooltip"].include? edu.title
							aux["tooltip"]+=edu.title+"<br>"
						end
					end
				end

				if count>0
					puts "!!!!!!!!!!!!!!!!!!!!!\n"+s.title+"->"+count.to_s+"\n"
					aux["n"]=count
					@sameContext<<aux
				end
			end

			@sameContext=@sameContext.sort_by { |hsh| -hsh["n"] }
			@sameContext=@sameContext[0..10]

			@graphOverall = LazyHighCharts::HighChart.new('graph') do |f|
				f.options[:plotOptions]={
					:line => {:lineWidth => 0}
				}
				f.options[:chart]={
					:width => 500,
					:height => 200
				}
				f.options[:title][:text] = "Objectives trend according to Bloom's Taxonomy"
				f.options[:xAxis]={
					:title => {:text => "Cognitive Dimension"},
					:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
					:tickPositions => [0,1,2,3,4,5,6],
					:gridLineWidth => '1',
					:lineWidth => 1,
	        		:tickmarkPlacement => 'on',
					:max => 6,
					:min => 0
				}
				f.options[:yAxis]={
					:title => {:text => "Knowledge Dimension"},
					:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
					:tickPositions => [0,1,2,3,4],
					:gridLineWidth => '1',
					:lineWidth => 1,
	        		:tickmarkPlacement => 'on',
					:max => 4,
					:min => 0
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
				f.options[:title][:text] = "Objectives identified according to Bloom's Taxonomy"
				f.options[:xAxis]={
					:title => {:text => "Cognitive Dimension"},
					:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
					:tickPositions => [0,1,2,3,4,5,6],
					:gridLineWidth => '1',
					:lineWidth => 1,
	        		:tickmarkPlacement => 'on',
					:max => 6,
					:min => 0
				}
				f.options[:yAxis]={
					:title => {:text => "Knowledge Dimension"},
					:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
					:tickPositions => [0,1,2,3,4],
					:gridLineWidth => '1',
					:lineWidth => 1,
	        		:tickmarkPlacement => 'on',
					:max => 4,
					:min => 0
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
		  end





		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
		
	end

	def infocourse()
		@serviceSelected=Service.find(params[:id])

		graph = RDF::Graph.load(@serviceSelected.path, :format => :ttl)

		# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
		queryUSDL4EDULanguage = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Language,
		    RDFS.label => :label
		  }
		})
		queryUSDL4EDUCycle = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.HighEducationCycle,
		    RDFS.label => :label,
		    DC.description => :description
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
		# cognitiveDimension=Hash.new
		# solutions=queryUSDL4EDCogn.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	cognitiveDimension[s.q]=c
		# end
		# knowledgeDimension=Hash.new
		# solutions=queryUSDL4EDKnow.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	knowledgeDimension[s.q]=c
		# end



		queryService = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.EducationalService,
		    USDL4EDU.hasDegree => :degree
		  }
		})
		queryDegree = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
		    DC.description => :description,
		    USDL4EDU.hasCycle => :cycleX,
		    USDL4EDU.hasEcts => :ects,
		    USDL4EDU.hasLanguage => :language
		  }
		})
		queryDegreeUnit = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
		    USDL4EDU.hasCourseUnit => :unit
		  }
		})


		queryUnitOB = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    USDL4EDU.hasTitle => :title,
		    USDL4EDU.hasOverallObjective => :obj
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

		solutionsService=queryService.execute(graph)
		solutionsDegree=queryDegree.execute(graph)
		solutionsDegreeUnit=queryDegreeUnit.execute(graph)

		solutionsUnitOB=queryUnitOB.execute(graph)
		solutionsOBCogn=queryOBCogn.execute(graph)
		solutionsOBKnow=queryOBKnow.execute(graph)
		
		itemDegree=""
		solutionsService.filter(:q => @serviceSelected.url).each do |solution|
			itemDegree=solution.degree
		end

		@selectedTable=[]


		@unit = Hash.new
		@unit["url"]=@serviceSelected.urlCourse
		@unit["language"]=[]
		@unit["unit"]=[]
		solutionsDegree.filter(:q => itemDegree).each do |solution|
			@unit["description"]=solution.description.to_s		

			solutions=queryUSDL4EDULanguage.execute(Webplatform::Application::GRAPHUSDL4EDU)
			solutions.filter(:q => solution.language).each do |solutionl|
				@unit["language"] << solutionl.label.to_s
			end

			solutions=queryUSDL4EDUCycle.execute(Webplatform::Application::GRAPHUSDL4EDU)
			solutions.filter(:q => solution.cycleX).each do |solutionl|
				cycle=Hash.new
				cycle["label"]=solutionl.label.to_s
				cycle["description"]=solutionl.description.to_s
				@unit["cycle"]=cycle
			end

			@unit["ects"]=solution.ects
		end
		solutionsDegreeUnit.filter(:q => itemDegree).each do |solution|
			u=Hash.new
			u["url"]=solution.unit
			@unit["unit"] << u
		end
		countCogn=0
		countKnow=0
		sumCogn=0
		sumKnow=0

		#bubble chart
		@a=[]
	  	@a[0]=[0,0,0,0,0]
	  	@a[1]=[0,0,0,0,0]
	  	@a[2]=[0,0,0,0,0]
	  	@a[3]=[0,0,0,0,0]
	  	@a[4]=[0,0,0,0,0]
	  	@a[5]=[0,0,0,0,0]
	  	@a[6]=[0,0,0,0,0]

	  	

		@unit["unit"].each do |u|
			solutionsUnitOB.filter(:q => u["url"]).each do |solutionUnit|
				selected=Hash.new
				selected["title"]=solutionUnit.title.to_s
				u["title"]=solutionUnit.title.to_s
				u["cogn"]=0
				solutionsOBCogn.filter(:q => solutionUnit.obj).each do |solutionOB|
					u["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
					countCogn+=1
					sumCogn+=u["cogn"]
				end
				u["know"]=0
				solutionsOBKnow.filter(:q => solutionUnit.obj).each do |solutionOB|
					u["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
					countKnow+=1
					sumKnow+=u["know"]
				end
				@a[u["cogn"]][u["know"]]+=1
				selected["cogn"]=u["cogn"]
				selected["know"]=u["know"]
				@selectedTable<<selected
			end
			solutionsUnitOB=queryUnitOB.execute(graph)
			solutionsOBCogn=queryOBCogn.execute(graph)
			solutionsOBKnow=queryOBKnow.execute(graph)
		end
		@unit["cogn"]=countCogn==0 ? 0 : (sumCogn/countCogn).round()
		@unit["know"]=countKnow==0 ? 0 : (sumKnow/countKnow).round()

		@selectedTable2=@selectedTable
		if params[:sort]
			if params[:sort]=="title"
				sselectedTable2=@selectedTable.sort_by{|hsh| hsh["title"]}
			else
				@selectedTable2=@selectedTable.sort_by{|hsh| [hsh["cogn"],-hsh["know"]]}
				@selectedTable2=@selectedTable2.sort_by{|hsh| [hsh["cogn"]==params[:sort].to_i ? 0 : 1, [hsh["cogn"],-hsh["know"]]]}
			end
		end

		# @graphOverall = LazyHighCharts::HighChart.new('graph') do |f|
		# 	f.options[:plotOptions]={
		# 		:line => {:lineWidth => 0}
		# 	}
		# 	f.options[:chart]={
		# 		:width => 500,
		# 		:height => 200
		# 	}
		# 	f.options[:title][:text] = "Avegare of Dregree according to Bloom's Taxonomy"
		# 	f.options[:xAxis]={
		# 		:title => {:text => "Cognitive Dimension"},
		# 		:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
		# 		:tickPositions => [0,1,2,3,4,5,6],
		# 		:gridLineWidth => '1',
		# 		:lineWidth => 1,
  #       		:tickmarkPlacement => 'on',
		# 		:max => 6,
		# 		:min => 0
		# 	}
		# 	f.options[:yAxis]={
		# 		:title => {:text => "Knowledge Dimension"},
		# 		:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
		# 		:tickPositions => [0,1,2,3,4],
		# 		:gridLineWidth => '1',
		# 		:lineWidth => 1,
  #       		:tickmarkPlacement => 'on',
		# 		:max => 4,
		# 		:min => 0
		# 	}
		# 	tmp="Average"
		# 	f.series(
		# 	:name=> tmp, 
		# 	:data=> [[@unit["cogn"] ? @unit["cogn"]: 0, @unit["know"] ? @unit["know"]: 0]],
		# 	:marker => {:radius=>6}
		# 	)
		# end

		@graphObjectives = LazyHighCharts::HighChart.new('graph') do |f|
			f.options[:exporting]={
				:enabled => true
			}
			f.options[:legend]={
				:width => 600,
				:itemWidth => 300,
				:adjustChartSize => true
			}
			f.options[:plotOptions]={
				:line => {:lineWidth => 0}
			}
			f.options[:title][:text] = "Objectives of each curricular unit according to Bloom's Taxonomy"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 6,
				:min => 0
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
				:tickPositions => [0,1,2,3,4],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 4,
				:min => 0
			}
			@unit["unit"].each do |u|
				if u['title']
					tmp="#{u['title']}"
					f.series(
						
						:name=> tmp, 
						:data=> [[u["cogn"] ? u["cogn"]: 0, u["know"] ? u["know"]: 0]],
						:marker => {:radius=>6}
					)
				end
			end
	  	end


	  	@data=[]
	  	for i in 0..(@a.size-1)
    		for j in 0..(@a[0].size-1)
	  			if @a[i][j]!=0
	  				aux=[]
	  				aux=[i,j,@a[i][j]]
	  				@data << aux
	  			end
	  		end
	  	end

	  	@graphObjectivesBubble = LazyHighCharts::HighChart.new('graph') do |f|
			f.option[:chart]={
				:type => "bubble",
				:plotBorderWidth => 1,
				:zoomType => 'xy'
			}
			f.options[:title][:text] = "Classification of curricular units according to Bloom's Taxonomy"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 6,
				:min => 0
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive",""],
				:tickPositions => [0,1,2,3,4,5],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 5,
				:min => -1,
				:startOnTick => false
			}

			f.series(
				:data=> @data,
				:name => @serviceSelected.title,	
                :marker=>{
                	:fillColor => {
                		:radialGradient => { cx: 0.4, cy: 0.3, r: 0.7 },
                		:stops => [
                         [0, 'rgba(0,255,0,0.5)'],
                         [1, 'rgba(69,114,167,0.5)']]
                	}
                }
			)
	  	end

	  	@context=ActiveSupport::OrderedHash.new
		Service.find(params[:id]).units.each do |u|
			u.educationalcontexts.each do |c|
				if not @context.has_key?(c.url)
					aux=Hash.new
					aux["label"]=c.title
					aux["n"]=1
					aux["units"]=u.title
					@context[c.url]=aux
				else
					@context[c.url]["n"]+=1
					@context[c.url]["units"]+="\n"+u.title
				end
			end
		end
		@final=Hash.new
		sorted = @context.sorted_hash{ |a, b| -a[1]["n"] <=> -b[1]["n"] }

		sorted.keys[0..10].each { |key| @final[key]=sorted[key] }




		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq

	end

	def view()
		@all=params[:ids].split("-")
		@idsS=[]
		@idsUS=[]
		@idsU=""

		@all.each do |sub|
		    if sub.ends_with? "u"
		        @idsUS<<sub[0..sub.size-2].to_i
		        @idsU+=sub+"-"
		    else
		        @idsS<<sub.to_i
		    end
		end
		@ids=@idsS.join("-")
		@idsU=@idsU[0..@idsU.size-2]


		if params[:idAdded]
			if params[:idAdded].ends_with? "u"
				if @all.include? params[:idAdded]
					flash[:notice] = Unit.find(params[:idAdded][0..params[:idAdded].size-2].to_i).title+" added to view"
				else
					flash[:notice] = Unit.find(params[:idAdded][0..params[:idAdded].size-2].to_i).title+" removed from view"
				end
			elsif params[:idAdded].ends_with? "c"
				flash[:notice] = "All units from "+Service.find(params[:idAdded][0..params[:idAdded].size-2].to_i).title+" added to view"
				
			else
				if @all.include? params[:idAdded]
					flash[:notice] = Service.find(params[:idAdded]).title+" added to view"
				else
					flash[:notice] = Service.find(params[:idAdded]).title+" removed from view"
				end
			end
		end

		@servicesSelected=Service.find(@idsS, :order=>"title")
		@unitsSelected=Unit.find(@idsUS, :order=>"title")

		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq


		# graphUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)
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
		# cognitiveDimension=Hash.new
		# solutions=queryUSDL4EDCogn.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	cognitiveDimension[s.q]=c
		# end
		# knowledgeDimension=Hash.new
		# solutions=queryUSDL4EDKnow.execute(Webplatform::Application::GRAPHUSDL4EDU)
		# solutions.each do |s|
		# 	c=Hash.new
		# 	c["label"]=s.label.to_s
		# 	c["description"]=s.description.to_s
		# 	c["value"]=s.value.to_i
		# 	knowledgeDimension[s.q]=c
		# end



		queryService2 = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.EducationalService,
		    USDL4EDU.hasCourseUnit => :unit
		  }
		})


		queryService = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.EducationalService,
		    USDL4EDU.hasDegree => :degree
		  }
		})
		queryDegree = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
		    DC.description => :description,
		    USDL4EDU.hasCycle => :cycleX,
		    USDL4EDU.hasEcts => :ects,
		    USDL4EDU.hasLanguage => :language
		  }
		})
		queryDegreeUnit = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.Degree,
		    USDL4EDU.hasCourseUnit => :unit,
		    USDL4EDU.hasTitle => :title
		  }
		})


		queryUnitOB = RDF::Query.new({
		  :q => {
		    RDF.type => USDL4EDU.CourseUnit,
		    USDL4EDU.hasTitle => :title,
		    USDL4EDU.hasOverallObjective => :obj
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


		#bubble chart
		@a=[]
	  	@a[0]=[0,0,0,0,0]
	  	@a[1]=[0,0,0,0,0]
	  	@a[2]=[0,0,0,0,0]
	  	@a[3]=[0,0,0,0,0]
	  	@a[4]=[0,0,0,0,0]
	  	@a[5]=[0,0,0,0,0]
	  	@a[6]=[0,0,0,0,0]

	  	countCogn=0
		countKnow=0
		sumCogn=0
		sumKnow=0
		@avgCogn=0
		@avgKnow=0

		@context=ActiveSupport::OrderedHash.new

		
		@selectedTable=[]

		@servicesSelected.each do |s|
			graph = RDF::Graph.load(s.path, :format => :ttl)
			solutionsUnitOB=queryUnitOB.execute(graph)
			solutionsOBCogn=queryOBCogn.execute(graph)
			solutionsOBKnow=queryOBKnow.execute(graph)


			selected=Hash.new

			if s.isCourse

				s.units.each do |u|
					u.educationalcontexts.each do |c|
						if not @context.has_key?(c.url)
							aux=Hash.new
							aux["label"]=c.title
							aux["n"]=1
							aux["units"]=s.title+" ("+u.title+")"
							@context[c.url]=aux
						else
							@context[c.url]["n"]+=1
							@context[c.url]["units"]+="\n"+s.title+" ("+u.title+")"
						end
					end
				end

				solutionsService=queryService.execute(graph)
				solutionsDegree=queryDegree.execute(graph)
				solutionsDegreeUnit=queryDegreeUnit.execute(graph)

				itemDegree=""
				solutionsService.filter(:q => s.url).each do |solution|
					itemDegree=solution.degree
				end

				unit = Hash.new
				unit["unit"]=[]
				solutionsDegreeUnit.filter(:q => itemDegree).each do |solution|
					u=Hash.new
					u["url"]=solution.unit
					unit["unit"] << u
					selected['title']=solution.title.to_s
				end

				cK=0
				cC=0
				sK=0
				sC=0

				unit["unit"].each do |u|
					solutionsUnitOB.filter(:q => u["url"]).each do |solutionUnit|
						u["title"]=solutionUnit.title.to_s
						u["cogn"]=0
						solutionsOBCogn.filter(:q => solutionUnit.obj).each do |solutionOB|
							u["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
							countCogn+=1
							cC+=1
							sC+=u["cogn"]
							sumCogn+=u["cogn"]
						end
						u["know"]=0
						solutionsOBKnow.filter(:q => solutionUnit.obj).each do |solutionOB|
							u["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
							countKnow+=1
							cK+=1
							sK+=u["know"]
							sumKnow+=u["know"]
						end
						@a[u["cogn"]][u["know"]]+=1
					end
					solutionsUnitOB=queryUnitOB.execute(graph)
					solutionsOBCogn=queryOBCogn.execute(graph)
					solutionsOBKnow=queryOBKnow.execute(graph)
				end

				selected["cogn"]=cC==0 ? 0 : (sC/cC).round()
				selected["know"]=cK==0 ? 0 : (sK/cK).round()

				@selectedTable<<selected
			else
				solutionsService2=queryService2.execute(graph)


				s.educationalcontexts.each do |c|
					if not @context.has_key?(c.url)
						aux=Hash.new
						aux["label"]=c.title
						aux["n"]=1
						aux["units"]=s.title
						@context[c.url]=aux
					else
						@context[c.url]["n"]+=1
						@context[c.url]["units"]+="\n"+s.title
					end
				end

				unit = Hash.new
				unit["unit"]=[]
				u=Hash.new
				solutionsService2.filter(:q => s.url).each do |solution|
					u["url"]=solution.unit
					unit["unit"] << u
				end

				cK=0
				cC=0
				sK=0
				sC=0

				unit["unit"].each do |u|
					solutionsUnitOB.filter(:q => u["url"]).each do |solutionUnit|
						selected["title"]=solutionUnit.title.to_s
						u["title"]=solutionUnit.title.to_s
						u["cogn"]=0
						solutionsOBCogn.filter(:q => solutionUnit.obj).each do |solutionOB|
							u["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
							countCogn+=1
							sumCogn+=u["cogn"]
							cC+=1
							sC+=u["cogn"]
						end
						u["know"]=0
						solutionsOBKnow.filter(:q => solutionUnit.obj).each do |solutionOB|
							u["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
							countKnow+=1
							sumKnow+=u["know"]
							cK+=1
							sK+=u["know"]
						end
						@a[u["cogn"]][u["know"]]+=1
					end
					solutionsUnitOB=queryUnitOB.execute(graph)
					solutionsOBCogn=queryOBCogn.execute(graph)
					solutionsOBKnow=queryOBKnow.execute(graph)
				end

				selected["cogn"]=cC==0 ? 0 : (sC/cC).round()
				selected["know"]=cK==0 ? 0 : (sK/cK).round()
				@selectedTable<<selected
			end
		end

		@unitsSelected.each do |s|
			selected=Hash.new


			s.educationalcontexts.each do |c|
				if not @context.has_key?(c.url)
					aux=Hash.new
					aux["label"]=c.title
					aux["n"]=1
					aux["units"]=s.title
					@context[c.url]=aux
				else
					@context[c.url]["n"]+=1
					@context[c.url]["units"]+="\n"+s.title
				end
			end


			service=s.service
			graph = RDF::Graph.load(service.path, :format => :ttl)
			solutionsUnitOB=queryUnitOB.execute(graph)
			solutionsOBCogn=queryOBCogn.execute(graph)
			solutionsOBKnow=queryOBKnow.execute(graph)

			u=Hash.new
			solutionsUnitOB.filter(:q => s.url).each do |solutionUnit|
				u["title"]=solutionUnit.title.to_s
				selected["title"]=u["title"]
				u["cogn"]=0
				solutionsOBCogn.filter(:q => solutionUnit.obj).each do |solutionOB|
					u["cogn"]=Webplatform::Application::COGNITIVEDIMENSION[solutionOB.cogn]["value"]
					countCogn+=1
					sumCogn+=u["cogn"]
				end
				u["know"]=0
				solutionsOBKnow.filter(:q => solutionUnit.obj).each do |solutionOB|
					u["know"]=Webplatform::Application::KNOWLEDGEDIMENSION[solutionOB.know]["value"]
					countKnow+=1
					sumKnow+=u["know"]
				end
				selected["cogn"]=u["cogn"]
				selected["know"]=u["know"]
				@a[u["cogn"]][u["know"]]+=1
			end
			@selectedTable<<selected
			solutionsUnitOB=queryUnitOB.execute(graph)
			solutionsOBCogn=queryOBCogn.execute(graph)
			solutionsOBKnow=queryOBKnow.execute(graph)

		end

		@a[0][0]=0
		@final=Hash.new
		sorted = @context.sorted_hash{ |a, b| -a[1]["n"] <=> -b[1]["n"] }

		sorted.keys[0..10].each { |key| @final[key]=sorted[key] }



		@selectedTable2=@selectedTable
		if params[:sort]
			if params[:sort]=="title"
				@selectedTable2=@selectedTable.sort_by{|hsh| hsh["title"]}
			else
				@selectedTable2=@selectedTable.sort_by{|hsh| [hsh["cogn"],-hsh["know"]]}
				@selectedTable2=@selectedTable2.sort_by{|hsh| [hsh["cogn"]==params[:sort].to_i ? 0 : 1, [hsh["cogn"],-hsh["know"]]]}
			end
		end

		@avgCogn=countCogn==0 ? 0 : (sumCogn/countCogn).round()
		@avgKnow=countKnow==0 ? 0 : (sumKnow/countKnow).round()

		@data=[]
	  	for i in 0..(@a.size-1)
    		for j in 0..(@a[0].size-1)
	  			if @a[i][j]!=0
	  				aux=[]
	  				aux=[i,j,@a[i][j]]
	  				@data << aux
	  			end
	  		end
	  	end

		# @graphOverall = LazyHighCharts::HighChart.new('graph') do |f|
		# 	f.options[:plotOptions]={
		# 		:line => {:lineWidth => 0}
		# 	}
		# 	f.options[:chart]={
		# 		:width => 500,
		# 		:height => 200
		# 	}
		# 	f.options[:title][:text] = "Average of Curricular units according to Bloom's Taxonomy"
		# 	f.options[:xAxis]={
		# 		:title => {:text => "Cognitive Dimension"},
		# 		:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
		# 		:tickPositions => [0,1,2,3,4,5,6],
		# 		:gridLineWidth => '1',
		# 		:lineWidth => 1,
  #       		:tickmarkPlacement => 'on',
		# 		:max => 6,
		# 		:min => 0
		# 	}
		# 	f.options[:yAxis]={
		# 		:title => {:text => "Knowledge Dimension"},
		# 		:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive"],
		# 		:tickPositions => [0,1,2,3,4],
		# 		:gridLineWidth => '1',
		# 		:lineWidth => 1,
  #       		:tickmarkPlacement => 'on',
		# 		:max => 4,
		# 		:min => 0
		# 	}
		# 	tmp="Average"
		# 	f.series(
		# 	:name=> tmp, 
		# 	:data=> [[@avgCogn ? @avgCogn: 0, @avgKnow ? @avgKnow: 0]],
		# 	:marker => {:radius=>6}
		# 	)
		# end

		@graphObjectivesBubble = LazyHighCharts::HighChart.new('graph') do |f|
			f.option[:chart]={
				:type => "bubble",
				:plotBorderWidth => 1,
				:zoomType => 'xy'
			}
			f.options[:title][:text] = "Classification of curricular units according to Bloom's Taxonomy"
			f.options[:xAxis]={
				:title => {:text => "Cognitive Dimension"},
				:categories => ["N/D", "Remember" ,"Understand" , "Apply" , "Analyze" , "Evaluate" , "Create"],
				:tickPositions => [0,1,2,3,4,5,6],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 6,
				:min => 0
			}
			f.options[:yAxis]={
				:title => {:text => "Knowledge Dimension"},
				:categories => ["N/D", "Factual" ,"Conceptual" , "Procedural" , "Meta-Cognitive",""],
				:tickPositions => [0,1,2,3,4,5],
				:gridLineWidth => '1',
				:lineWidth => 1,
	    		:tickmarkPlacement => 'on',
				:max => 5,
				:min => -1,
				:startOnTick => false
			}

			f.series(
				:data=> @data,
				:name => "Services selected above",	
                :marker=>{
                	:fillColor => {
                		:radialGradient => { cx: 0.4, cy: 0.3, r: 0.7 },
                		:stops => [
                         [0, 'rgba(0,255,0,0.5)'],
                         [1, 'rgba(69,114,167,0.5)']]
                	}
                }
			)
	  	end


	end
end

class Hash
  def sorted_hash(&block)
    self.class[sort(&block)]   # Hash[ [[key1, value1], [key2, value2]] ]
  end
end