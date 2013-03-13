from rdflib.graph import Graph, ConjunctiveGraph
from rdflib import Literal, BNode, Namespace, URIRef
from rdflib import RDF,RDFS

graph = Graph()
#graph.parse('http://rdf.genssiz.dei.uc.pt/usdl4edu#')

# graph.bind('usdl4edu','http://rdf.genssiz.dei.uc.pt/usdl4edu#')
# USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")


# online=URIRef(USDL4EDU["ModeDeliveryOnline"])
# pres=URIRef(USDL4EDU["ModeDeliveryPres"])
# pt=URIRef(USDL4EDU["LanguagePT"])
# en=URIRef(USDL4EDU["LanguageEN"])


# service=URIRef(USDL4EDU+'service1')
# graph.add((service,RDF.type,USDL4EDU["CourseUnit"]))
# graph.add((service,USDL4EDU["hasEcts"],Literal(6)))
# graph.add((service,USDL4EDU["hasDeliveryMode"],online))
# graph.add((service,USDL4EDU["hasLanguage"],pt))


#graph.bind('usdl4edu','http://rdf.genssiz.dei.uc.pt/usdl4edu#')
#USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")

#graph.bind('skos','http://www.w3.org/2004/02/skos/core#')
#SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")

# concept=URIRef(SKOS+'Concept')
# conceptScheme=URIRef(SKOS+'ConceptScheme')

# acm=URIRef(USDL4EDU+'acm-conceptscheme')
# graph.add((acm,RDF.type,conceptScheme))


graph.parse("context.ttl",format='n3')
print len(graph)
graph.parse("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
print len(graph)
SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
for c in graph.subjects(RDF.type,RDFS.Class):
	for title in graph.objects(c, RDFS.label):
		print title

print "JA FOI"
for concept in graph.subjects(RDF.type,SKOS["Concept"]):
	for label in graph.objects(concept, SKOS["prefLabel"]):
		print label.encode('utf-8')

#print graph.serialize(format='n3')

#University


# graph.add((service,USDL4EDU["hasUniversity"],USDL4EDU["Service"]))
# graph.add((service,RDF.type,USDL4EDU["Service"]))
