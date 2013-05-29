require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Webplatform
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    NS="http://rdf.genssiz.dei.uc.pt/usdl4edu#"
    DC=RDF::Vocabulary.new "http://purl.org/dc/terms/"
    SKOS=RDF::Vocabulary.new "http://www.w3.org/2004/02/skos/core#"
    FOAF=RDF::Vocabulary.new "http://xmlns.com/foaf/spec/"
    RDFS=RDF::Vocabulary.new "http://www.w3.org/2000/01/rdf-schema#"
    USDL4EDU = RDF::Vocabulary.new NS

    GRAPHUSDL4EDU = RDF::Graph.load("public/services/usdl4edu.ttl", :format => :ttl)



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
    COGNITIVEDIMENSION=Hash.new
    solutions=queryUSDL4EDCogn.execute(GRAPHUSDL4EDU)
    solutions.each do |s|
        c=Hash.new
        c["label"]=s.label.to_s
        c["description"]=s.description.to_s
        c["value"]=s.value.to_i
        COGNITIVEDIMENSION[s.q]=c
    end
    KNOWLEDGEDIMENSION=Hash.new
    solutions=queryUSDL4EDKnow.execute(GRAPHUSDL4EDU)
    solutions.each do |s|
        c=Hash.new
        c["label"]=s.label.to_s
        c["description"]=s.description.to_s
        c["value"]=s.value.to_i
        KNOWLEDGEDIMENSION[s.q]=c
    end

  end
end
