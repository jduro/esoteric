class WelcomeController < ApplicationController
	NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
	DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
	USDL4EDU = RDF::Vocabulary.new NS


	def index()
		@isIndex=true

		@services=Service.all




	end

	def import()
		name = params[:file].original_filename
	    directory = "public/services/upload"
	    path = File.join(directory, name)
	    File.open(path, "wb") { |f| f.write(params[:file].read) }
		# flash[:notice] = "File uploaded"

		graph = RDF::Graph.load(path, :format => :ttl)

		puts "OLA"
		RDF::Query.new({q: {RDF.type => USDL4EDU.EducationalService}}).execute(graph).each do |s|
			service=Service.new
			service.url=s.q.to_s
			RDF::Query.new({q: {DC.description => :description}}).execute(graph).each do |s2|
				service.description=s2.description
				service.title=s2.description.to_s.gsub(/ - .*/,"")
			end
			service.path=path
			service.save
		end
		redirect_to action: "index"
	end
end
