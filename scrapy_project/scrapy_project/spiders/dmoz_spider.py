from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector

from scrapy_project.items import DmozItem,EducationalService,ContextItem

import sys

class DmozSpider(BaseSpider):
    name = "dmoz"
    allowed_domains = ["dmoz.org"]
    start_urls = [
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Books/",
        "http://www.dmoz.org/Computers/Programming/Languages/Python/Resources/"
    ]

    def parse(self, response):
        hxs = HtmlXPathSelector(response)
        sites = hxs.select('//ul/li')
        items=[]
        for site in sites:
			item = DmozItem()
			item['title'] = site.select('a/text()').extract()
			item['link'] = site.select('a/@href').extract()
			item['desc'] = site.select('text()').extract()
			items.append(item)
            # print title
            # print link
            # print desc
            # print "----------------------------------"
        return items

class UdacitySpider(BaseSpider):
	name="udacity"
	allowed_domains=["udacity.com"]
	start_urls=["https://www.udacity.com/course/cs271"]

	def parse(self, response):
		hxs = HtmlXPathSelector(response)
		item = EducationalService()
		item['title']=hxs.select('//h1/text()').extract()
		
		#print item['title']





class ACMSpider(BaseSpider):
    name="acm"
    start_urls=["http://dl.acm.org/ccs_flat.cfm"]

    def parse(self, response):
        hxs = HtmlXPathSelector(response)

        lis=hxs.select("./body/div/div/ul/li")
        # for li in lis:
        #     title = li.select('./div/a/text()')

        #     ul=li.select('./ul')
        #     print title.extract()
        # print lis[1].select('./ul/*').extract()
        items=[]
        items=getContext(lis)
        print "got all items"
        #printContext(items,0)

        return items


def printContext(items,tab):
    for item in items:
        for i in range(tab):
            print('\t'),
            #sys.stdout.write('\t')
        #sys.stdout.write(item['title'])
        print(item['title'])
        if len(item['subContext'])!=0:
            printContext(item['subContext'],tab+1)
        


def getContext(lis):
    items=[]
    for li in lis:
        item = ContextItem()
        item['subContext'] = []
        item['title'] = li.select('./div/a/text()').extract()
        if len(item['title'])==0:
            item['title'] = li.select('./a/text()').extract()
        #print item['title']
        #print item['title']
        ul=li.select('./ul/*')
        #print len(ul)
        if len(ul)!=0 :
            item['subContext']=getContext(ul)
        items.append(item)
    # print item['title']
    # print len(item['subContext'])
    # print item['subContext']
    # print "-----"
    return items