# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/topics/item-pipeline.html
from scrapy import signals
from scrapy.xlib.pydispatch import dispatcher
from rdflib.graph import Graph, ConjunctiveGraph
from rdflib import Literal, BNode, Namespace, URIRef
from rdflib import RDF, RDFS


class ScrapyProjectPipeline(object):
	def __init__(self):
		print "INIT"
		dispatcher.connect(self.open_spider, signals.spider_opened)
		dispatcher.connect(self.close_spider, signals.spider_closed)

	def process_item(self, item, spider):
		# print type(str(item['title']))
		# print type(item['title'])
		if spider.name=="acm":
			#context=URIRef(self.USDL4EDU+str(item['title'][0].replace(" ","-").replace(":-","-").replace(",-","-"))+str(self.value))
			context=URIRef(self.USDL4EDU+"acm"+str(self.value))
			self.graph.add((context,RDF.type,self.concept))
			self.graph.add((context,self.SKOS["prefLabel"],Literal(str(item['title'][0]))))
			self.graph.add((self.acm,self.SKOS["hasTopConcept"],context))
			if len(item['subContext'])!=0:
				self.addContext(item['subContext'],str(self.value)+'-',context)
			self.value+=1
		return item

	def addContext(self,items,num,father):
		value=0
		for item in items:
			value+=1
			#context=URIRef(self.USDL4EDU+str(item['title'][0].replace(" ","-").replace(":-","-").replace(",-","-"))+num+str(value))
			context=URIRef(self.USDL4EDU+"acm"+num+str(value))
			#O PAI TEM ESTE FILHO MAIS GENERICO
			self.graph.add((father,self.SKOS["narrowerGeneric"],context))
			#O FILHO TEM UM PAI MAIS ESPECIFICO
			self.graph.add((context,self.SKOS["broaderGeneric"],father))
			self.graph.add((context,RDF.type,self.concept))
			self.graph.add((context,self.SKOS["prefLabel"],Literal(item['title'][0])))
			if len(item['subContext'])!=0:
				self.addContext(item['subContext'],num+str(value)+'-',context)

	def open_spider(self,spider):
		self.value=1
		self.graph=Graph()
		self.initialize_uris_skos()
		return

	def close_spider(self,spider):
		print self.graph.serialize("context.ttl",format='n3')
		return


	def initialize_uris_skos(self):
		self.graph.bind('usdl4edu','http://rdf.genssiz.dei.uc.pt/usdl4edu#')
		self.USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")

		self.graph.bind('skos','http://www.w3.org/2004/02/skos/core#')
		self.SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")

		self.concept=URIRef(self.SKOS+'Concept')
		self.conceptScheme=URIRef(self.SKOS+'ConceptScheme')

		self.acm=URIRef(self.USDL4EDU+'acm-conceptscheme')
		self.graph.add((self.acm,RDF.type,self.conceptScheme))


   
