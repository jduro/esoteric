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


# graph.parse("context.ttl",format='n3')
# print len(graph)
# graph.parse("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
# print len(graph)
# SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
# USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
# for c in graph.subjects(RDF.type,RDFS.Class):
# 	for title in graph.objects(c, RDFS.label):
# 		print title

# print "JA FOI"
# for concept in graph.subjects(RDF.type,SKOS["Concept"]):
# 	for label in graph.objects(concept, SKOS["prefLabel"]):
# 		print label.encode('utf-8')

#print graph.serialize(format='n3')

#University


# graph.add((service,USDL4EDU["hasUniversity"],USDL4EDU["Service"]))
# graph.add((service,RDF.type,USDL4EDU["Service"]))



##--------------------##
# Checking keywords in objectives
graphUSDL4EDU=Graph()
graphUSDL4EDU.parse("\commondata\usdl4edu.ttl",format='n3')
USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
DC = Namespace("http://purl.org/dc/terms/")


graphConcepts=Graph()
graphConcepts.parse("\commondata\exported\context.ttl",format='n3')
SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")

keywords=[]
for obj in graphUSDL4EDU.subjects(RDF.type,USDL4EDU["CognitiveDimension"]):
	# aux=[]
	for mbox in graphUSDL4EDU.objects(obj,USDL4EDU["hasKeyword"]):
		# aux.append(str(mbox))
		keywords.append(str(mbox))
		# print mbox

graph=Graph()
graph.parse("\commondata\exported\udacity.ttl",format='n3')
description=""
number_descriptions=0
number_found=0
number_context=0
for obj in graph.subjects(RDF.type,USDL4EDU["OverallObjective"]):
	for mbox in graph.objects(obj,DC["description"]):
		number_descriptions+=1
		# if obj==URIRef(USDL4EDU["Organizao-Comportamento-Conhecimento-e-Inovao-objectives"]):
		# 	description=mbox
		# print mbox.encode("utf-8")
		# print mbox
		for k in keywords:
			if " "+k+" " in mbox or mbox in " "+k+" ":
				number_found+=1
				print obj
				print k
				print mbox[mbox.find(k):mbox.find(k)+75].encode("utf-8").strip()
				for o in graphConcepts.subjects(RDF.type,SKOS["Concept"]):
					for m in graphConcepts.objects(o,SKOS["prefLabel"]):
						context=m.split(" ")
						total=0
						for c in context:
							if c in mbox[mbox.find(k):mbox.find(k)+75]:
								total+=1
						if total>(len(context)/2):
							print m
							print "Got "+str(total)+" words of "+str(len(context))
							number_context+=1
				print "---"
	# for k in self.keywords:
	# 	if " "+k+" " in unitItem["objectives"]:
	# 		print unitItem["title"]
	# 		print k
	# 		print unitItem["objectives"][unitItem["objectives"].find(k)-30:unitItem["objectives"].find(k)+31]
	# 		print "---"
# description=description[:description.find("Ingl")].strip()
# graphOnto=Graph()
# graphOnto.parse("\commondata\dicionarios\Onto.PT.0.4.1.rdfs")
# ONTOPT = Namespace("http://ontopt.dei.uc.pt/OntoPT.owl#")

# for obj in graphOnto.subjects(RDF.type,ONTOPT["VerboSynset"]):
# 	for mbox in graphOnto.objects(obj,ONTOPT["formaLexical"]):
# 		if " "+mbox+" " in description:
# 			print obj
# 			print mbox.encode("utf-8")
# 			print description[description.find(mbox):description.find(mbox)+len(mbox)].encode("utf-8")
# 			print "------"
print str(number_descriptions) +" Descrptions"
print str(number_found) +" Found"
print str(number_context) +" Context"
# for i in range(len(keywords)):
# 	for k in range(i+1,len(keywords)):
# 		if keywords[i]==keywords[k]:
# 			print keywords[i]+" pos:"+str(i)
# 			print keywords[k]+" pos:"+str(k)
# 			print "---"