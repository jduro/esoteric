# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/topics/item-pipeline.html
from scrapy import signals
from scrapy.xlib.pydispatch import dispatcher
from rdflib.graph import Graph, ConjunctiveGraph
from rdflib import Literal, BNode, Namespace, URIRef
from rdflib import RDF, RDFS
from scrapy.http import Request, FormRequest


class ScrapyProjectPipeline(object):
	def __init__(self):
		#Recall function to open/close spider
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
		elif spider.name=="udacity":
			#See http://rdf.genssiz.dei.uc.pt/usdl4edu# for Ontology schema
			#Educational Service
			service=URIRef(self.USDL4EDU+str(item['title'][0].encode("ascii","replace")).strip().replace(" ","-")+"-service")
			self.graph.add((service,RDF.type,self.educationalService))
			self.graph.add((service,self.DC["description"],Literal(str(item['title'][0]).strip()+" - Educational service from Udacity")))
			self.graph.add((service,self.USDL4EDU["hasOrganization"],self.organization))
			self.graph.add((service,self.USDL4EDU["hasURL"],Literal(item["url"])))
			#Curricular Unit
			unit=URIRef(self.USDL4EDU+str(item['title'][0]).strip().replace(" ","-")+"-unit")
			self.graph.add((unit,RDF.type,self.courseUnit))
			self.graph.add((service,self.USDL4EDU["hasCourseUnit"],unit))
			self.graph.add((unit,self.USDL4EDU["hasTitle"],Literal(str(item['title'][0].encode("ascii","replace")).strip())))
			self.graph.add((unit,self.DC["description"],Literal(str(item['summary'][0].encode("ascii","replace")))))
			self.graph.add((unit,self.USDL4EDU["hasDeliveryMode"],self.modeDeliveryOnline))
			self.graph.add((unit,self.USDL4EDU["hasLanguage"],self.languageEN))
			#TEACHERS (not check existing, rdflib doesn't add a existing one)
			for t in item['teachers']:
				teacher=URIRef(self.USDL4EDU+str(t['name'][0].encode("ascii","ignore")).strip().replace(" ","-"))
				self.graph.add((teacher,RDF.type,self.person))
				name=str(t['name'][0].encode("ascii","replace")).strip().split(" ")
				self.graph.add((teacher,self.FOAF["firstName"],Literal(name[0])))
				self.graph.add((teacher,self.FOAF["lastName"],Literal(name[1])))
				self.graph.add((teacher,self.FOAF["status"],Literal(str(t['bio'][0].encode("ascii","replace")))))

				self.graph.add((unit,self.USDL4EDU["hasTeacher"],teacher))

			#Overall Prerequisite
			overallPrereq=URIRef(self.USDL4EDU+str(item['title'][0]).strip().replace(" ","-")+"-prerequisites")
			self.graph.add((overallPrereq,RDF.type,self.overallprereq))
			self.graph.add((overallPrereq,self.DC["description"],Literal(str(item['prereq'][0].encode("ascii","replace")))))
			self.graph.add((unit,self.USDL4EDU["hasOverallPrerequisite"],overallPrereq))
			#Overall Objectives
			overallObj=URIRef(self.USDL4EDU+str(item['title'][0]).strip().replace(" ","-")+"-objectives")
			self.graph.add((overallObj,RDF.type,self.overallObjective))
			self.graph.add((overallObj,self.DC["description"],Literal(item['objectives'])))
			self.graph.add((unit,self.USDL4EDU["hasOverallObjective"],overallObj))
			self.parseOverallObjective(item['objectives'].replace("\n",""),overallObj,str(item['title'][0]).strip())
			self.number_descriptions+=1
		elif spider.name=="nonio" and item['size']==len(item['courseUnits']):
			# print "---- PIPELINE ----"
			# print item['title']
			# for unit in item['courseUnits']:
			# 	print "\tTitle: "+unit['title']
			# 	print "\t\tObje: "+unit['objectives']
			# 	print "\t\tPre: "+unit['prereq']
			# 	print "\t\tTeacher: "+unit['teachers']
			# print "---- end pipeline ----"
			


			#Savin acronym to use in file name
			if item["acronym"]:
				self.acronym=item["acronym"]
			else:
				self.acronym=item["title"].decode('utf-8').encode("ascii","ignore").replace(" ","-")

			print self.acronym

			#See http://rdf.genssiz.dei.uc.pt/usdl4edu# for Ontology schema
			#Educational Service
			service=URIRef(self.USDL4EDU+item['title'].decode('utf-8').encode("ascii","ignore").replace(" ","-")+"-service")
			self.graph.add((service,RDF.type,self.educationalService))
			self.graph.add((service,self.DC["description"],Literal(item['title']+" - Educational service from Department of Informatics Engineering - University of Coimbra")))
			self.graph.add((service,self.USDL4EDU["hasOrganization"],self.organization))
			self.graph.add((service,self.USDL4EDU["hasURL"],Literal("http://www.uc.pt/en/fctuc/dei")))
			#Degree
			degree=URIRef(self.USDL4EDU+item['title'].decode('utf-8').encode("ascii","ignore").replace(" ","-")+"-degree")
			self.graph.add((degree,RDF.type,self.degree))
			self.graph.add((service,self.USDL4EDU["hasDegree"],degree))
			self.graph.add((degree,self.USDL4EDU["hasTitle"],Literal(item['title'])))

			self.graph.add((degree,self.DC["description"],Literal(item['objectives'])))
			print "----"+item['ects']
			self.graph.add((degree,self.USDL4EDU["hasEcts"],Literal(item['ects'])))
			if "1" in item["academicDegree"]:
				self.graph.add((degree,self.USDL4EDU["hasCycle"],self.firstCycle))
			elif "2" in item["academicDegree"]:
				self.graph.add((degree,self.USDL4EDU["hasCycle"],self.secondCycle))
			elif "3" in item["academicDegree"]:
				self.graph.add((degree,self.USDL4EDU["hasCycle"],self.thirdCycle))
			if "Portugu" in item["languages"]:
				self.graph.add((degree,self.USDL4EDU["hasLanguage"],self.languagePT))
			if "Ingl" in item["languages"]:
				self.graph.add((degree,self.USDL4EDU["hasLanguage"],self.languageEN))

			for unitItem in item["courseUnits"]:
				#Curricular Unit
				unit=URIRef(self.USDL4EDU+unitItem['title'].decode('utf-8').encode("ascii","ignore").replace(" ","-").replace("/","").replace(",","").replace(":","")+"-unit")
				self.graph.add((unit,RDF.type,self.courseUnit))
				self.graph.add((degree,self.USDL4EDU["hasCourseUnit"],unit))
				self.graph.add((unit,self.USDL4EDU["hasTitle"],Literal(unitItem['title'])))
				if not ("o definida. " in unitItem['summary']):
					self.graph.add((unit,self.DC["description"],Literal(unitItem['summary'])))
				if "Presencial" in unitItem["deliverymode"]:
					self.graph.add((unit,self.USDL4EDU["hasDeliveryMode"],self.modeDeliveryPres))
				if "Portugu" in unitItem["language"]:
					self.graph.add((unit,self.USDL4EDU["hasLanguage"],self.languagePT))
				if "Ingl" in unitItem["language"]:
					self.graph.add((unit,self.USDL4EDU["hasLanguage"],self.languageEN))
				self.graph.add((unit,self.USDL4EDU["hasEcts"],Literal(unitItem['ects'])))
				if "1" in unitItem["semester"]:
					self.graph.add((unit,self.USDL4EDU["hasSemester"],Literal(1)))
				else:
					self.graph.add((unit,self.USDL4EDU["hasSemester"],Literal(2)))

				if unitItem['prereq'] and not ("o definida. " in unitItem['prereq']):
					#Overall Prerequisite
					overallPrereq=URIRef(self.USDL4EDU+unitItem['title'].decode('utf-8').encode("ascii","ignore").replace(" ","-").replace("/","").replace(",","").replace(":","")+"-prerequisites")
					self.graph.add((overallPrereq,RDF.type,self.overallprereq))
					self.graph.add((overallPrereq,self.DC["description"],Literal(unitItem['prereq'])))
					self.graph.add((unit,self.USDL4EDU["hasOverallPrerequisite"],overallPrereq))
				if unitItem['objectives'] and not ("o definida. " in unitItem['objectives']):
					#Overall Objectives
					overallObj=URIRef(self.USDL4EDU+unitItem['title'].decode('utf-8').encode("ascii","ignore").replace(" ","-").replace("/","").replace(",","").replace(":","")+"-objectives")
					self.graph.add((overallObj,RDF.type,self.overallObjective))
					self.graph.add((overallObj,self.DC["description"],Literal(unitItem['objectives'])))
					self.graph.add((unit,self.USDL4EDU["hasOverallObjective"],overallObj))
				if unitItem["teachers"]:
					teacher=URIRef(self.USDL4EDU+str(unitItem["teachers"].decode('utf-8').encode("ascii","ignore").replace(" ","-")))
					self.graphPersons.add((teacher,RDF.type,self.person))
					name=unitItem["teachers"].split(" ")
					self.graphPersons.add((teacher,self.FOAF["firstName"],Literal(name[0])))
					self.graphPersons.add((teacher,self.FOAF["lastName"],Literal(name[len(name)-1])))

					self.graph.add((unit,self.USDL4EDU["hasTeacher"],teacher))
				for k in self.keywords:
					if " "+k+" " in unitItem["objectives"]:
						print unitItem["title"]
						print k
						print unitItem["objectives"][unitItem["objectives"].find(k)-30:unitItem["objectives"].find(k)+31]
						print "---"

		return item

	def parseOverallObjective(self, overallObj, overallObjRef, title):
		overallObj=overallObj.lower()
		check=0
		number=0
		for obj in self.graphUSDL4EDU.subjects(RDF.type,self.USDL4EDU["CognitiveDimension"]):
			for mbox in self.graphUSDL4EDU.objects(obj,self.USDL4EDU["hasKeyword"]):
				if " "+mbox+" " in overallObj or overallObj in " "+mbox+" ":
					mbox=mbox.lower()
					check=1
					self.number_found+=1
					print "TUDO:"+overallObj
					print "VERBO:"+mbox
					print "OBJ:"+obj
					print "Inicio-Fim:"+overallObj[overallObj.find(mbox):].encode("utf-8").strip()
					aux= overallObj[overallObj.find(mbox):].strip()
					if aux.find(".")!=-1:
						aux=aux[:aux.find(".")]
					print "**"
					print "Inicio-ponto:"+aux

					#Objective
					number+=1
					objective=URIRef(self.USDL4EDU+title.encode("ascii","ignore").replace(" ","-").replace("/","").replace(",","").replace(":","")+"-objective"+str(number))
					self.graph.add((objective,RDF.type,self.objectiveEDU))
					self.graph.add((objective,self.DC["description"],Literal(aux)))
					self.graph.add((objective,self.USDL4EDU["hasCognitiveDimension"],obj))
					

					for o in self.graphConcepts.subjects(RDF.type,self.SKOS["Concept"]):
						for m in self.graphConcepts.objects(o,self.SKOS["prefLabel"]):
							m=m.lower()
							context=m.split(" ")
							total=0
							small_words=0
							for c in context:
								if len(c)<=3:
									small_words+=1
								elif c in aux:
									total+=1
							if total>((len(context)-small_words)/2):
								self.graph.add((objective,self.USDL4EDU["hasContext"],o))
								print "Context:"+m
								print "Got "+str(total)+" words of "+str(len(context))
								self.number_context+=1
					print "---"

					self.graph.add((overallObjRef,self.USDL4EDU["hasPartObjective"],objective))
		if check==0:
			print "Sem nada: "+overallObj
			#Objective
			objective=URIRef(self.USDL4EDU+title.encode("ascii","ignore").replace(" ","-").replace("/","").replace(",","").replace(":","")+"-objective")
			self.graph.add((objective,RDF.type,self.objectiveEDU))
			self.graph.add((objective,self.DC["description"],Literal(overallObj)))

			for o in self.graphConcepts.subjects(RDF.type,self.SKOS["Concept"]):
				for m in self.graphConcepts.objects(o,self.SKOS["prefLabel"]):
					m=m.lower()
					if " "+m in overallObj:
						print "<>Context:"+ m
						self.graph.add((objective,self.USDL4EDU["hasContext"],o))
						self.number_context+=1
					# context=m.split(" ")
					# total=0
					# last=-1
					# for c in context:
					# 	if c in overallObj:
					# 		if last!=-1:
					# 			print abs(last-overallObj.find(c))
					# 		if abs(last-overallObj.find(c))<75:
					# 			total+=1
					# 		if len(c)>3:
					# 			last=overallObj.find(c)

					# if total>(len(context)/2):
					# 	print "<>Context:"+m
					# 	print "<>Got "+str(total)+" words of "+str(len(context))
					# 	self.number_context+=1
			self.number_wihout+=1
			print "----"
			self.graph.add((overallObjRef,self.USDL4EDU["hasPartObjective"],objective))

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
		if spider.name=="acm":
			self.value=1
			self.graph=Graph()
			self.initialize_uris_skos()
		elif spider.name=="udacity":
			self.graph=Graph()
			self.graphConcepts=Graph()
			self.graphUSDL4EDU=Graph()
			self.graphPersons=Graph()
			self.graphPersons.parse("commondata\exported\\nonio_persons.ttl",format='n3')
			self.initialize_uris_usdl4edu()			
			self.organization=URIRef(self.USDL4EDU+"udacity")
			self.graph.add((self.organization,RDF.type,self.FOAF["Organization"]))
			self.graph.add((self.organization,self.DC["description"],Literal("Udacity")))

			self.graphConcepts=Graph()
			self.graphConcepts.parse("\commondata\exported\context.ttl",format='n3')
			self.SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")

			#Statistic
			self.number_descriptions=0
			self.number_found=0
			self.number_context=0
			self.number_wihout=0
		elif spider.name=="nonio":
			self.graph=Graph()
			self.graphPersons=Graph()
			self.graphPersons.parse("commondata\exported\\nonio_persons.ttl",format='n3')
			self.graphConcepts=Graph()
			self.graphUSDL4EDU=Graph()
			self.initialize_uris_usdl4edu()
			self.organization=URIRef(self.USDL4EDU+"dei-uc")
			self.graph.add((self.organization,RDF.type,self.FOAF["Organization"]))
			self.graph.add((self.organization,self.DC["description"],Literal("Department of Informatics Engineering - University of Coimbra")))
			self.firstCycle=URIRef(self.USDL4EDU+'HighEducationCycle_1st')
			self.secondCycle=URIRef(self.USDL4EDU+'HighEducationCycle_2nd')
			self.thirdCycle=URIRef(self.USDL4EDU+'HighEducationCycle_3rd')

			self.number=0

			self.keywords=[]
			for obj in self.graphUSDL4EDU.subjects(RDF.type,self.USDL4EDU["CognitiveDimension"]):
				# aux=[]
				for mbox in self.graphUSDL4EDU.objects(obj, self.USDL4EDU["hasKeyword"]):
					self.keywords.append(str(mbox))
				# 	aux.append(str(mbox))
				# 	print mbox
				# keywords.append(aux)

		return

	def close_spider(self,spider):
		if spider.name=="acm":
			print self.graph.serialize("commondata\exported\context.ttl",format='n3')
		elif spider.name=="udacity":
			# print "NOT SAVING"
			print self.number_descriptions
			print self.number_found
			print self.number_context
			print self.number_wihout
			self.graph.serialize("commondata\exported\udacity2.ttl",format='n3')
		elif spider.name=="nonio":
			print "NOT SAVING"
			# self.graph.serialize("commondata\exported\\nonio_"+self.acronym+".ttl",format='n3')
			# self.graphPersons.serialize("commondata\exported\\nonio_persons.ttl",format='n3')
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

	def initialize_uris_usdl4edu(self):
		self.graph.bind('usdl4edu','http://rdf.genssiz.dei.uc.pt/usdl4edu#')
		self.graph.bind('skos','http://www.w3.org/2004/02/skos/core#')
		self.graph.bind('foaf','http://xmlns.com/foaf/spec/')
		self.graph.bind('dc','http://purl.org/dc/terms/')

		self.graphPersons.bind('usdl4edu','http://rdf.genssiz.dei.uc.pt/usdl4edu#')
		self.graphPersons.bind('skos','http://www.w3.org/2004/02/skos/core#')
		self.graphPersons.bind('foaf','http://xmlns.com/foaf/spec/')
		self.graphPersons.bind('dc','http://purl.org/dc/terms/')

		self.USDL4EDU = Namespace("http://rdf.genssiz.dei.uc.pt/usdl4edu#")
		self.FOAF = Namespace("http://xmlns.com/foaf/spec/")
		self.SKOS = Namespace("http://www.w3.org/2004/02/skos/core#")
		self.DC = Namespace("http://purl.org/dc/terms/")

		self.educationalService=URIRef(self.USDL4EDU+'EducationalService')
		self.courseUnit=URIRef(self.USDL4EDU+'CourseUnit')

		self.language=URIRef(self.USDL4EDU+'Language')
		self.languagePT=URIRef(self.USDL4EDU+'LanguagePT')
		self.languageEN=URIRef(self.USDL4EDU+'LanguageEN')

		self.modeDelivery=URIRef(self.USDL4EDU+'ModeDelivery')
		self.modeDeliveryOnline=URIRef(self.USDL4EDU+'ModeDeliveryOnline')
		self.modeDeliveryPres=URIRef(self.USDL4EDU+'ModeDeliveryPres')

		self.objective=URIRef(self.USDL4EDU+'Concept')
		self.overallObjective=URIRef(self.USDL4EDU+'OverallObjective')

		self.objectiveEDU=URIRef(self.USDL4EDU+'Objective')

		self.concept=URIRef(self.SKOS+'Objective')
		self.overallprereq=URIRef(self.USDL4EDU+'OverallPrerequisite')

		self.person=URIRef(self.FOAF+"Person")

		self.degree=URIRef(self.USDL4EDU+'Degree')

		self.graphUSDL4EDU.parse("\commondata\usdl4edu.ttl",format='n3')
		self.graphConcepts.parse("\commondata\exported\context.ttl",format='n3')
