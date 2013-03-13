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
		#dispatcher.connect(self.close_spider, signals.spider_closed)

	def process_item(self, item, spider):
		print self.value
		self.value+=1
		if spider.name=="acm":
			if 'title' in item:
				print item['title']
			if 'subContext' in item:
				print "tem filhos"
		return item

	def open_spider(self,spider):
		print "COMECOU SPIDER"
		
		self.value=0
		return

   
