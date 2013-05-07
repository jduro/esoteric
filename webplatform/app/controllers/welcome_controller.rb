class WelcomeController < ApplicationController
	NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
	DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
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
			RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService, DC.description => :description, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasOrganization => :organization, USDL4EDU.hasURL => :urlCourse}}).execute(graph).each do |s|
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
		@a=graph.query([RDF::URI.new(@serviceSelected.url)])
		# flash[:notice]=a

		@isIndex=true

		@services=Service.all
		@organizations=Service.select(:organization).map(&:organization).uniq
	end
end
