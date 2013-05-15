from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.spiders.init import InitSpider
from scrapy.http import Request, FormRequest
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor
from scrapy_project.items import DmozItem,EducationalServiceItem,ContextItem,StbItem,TeacherItem,DegreeItem,UnitItem
from scrapy.utils.response import open_in_browser
from scrapy.shell import inspect_response
from time import time, sleep
import urlparse

from selenium import selenium
import time
import sys

class UdacitySpider(CrawlSpider):
    name="udacity"
    allowed_domains=["udacity.com"]
    start_urls=["https://www.udacity.com/courses"]
    rules = (
        Rule(
            SgmlLinkExtractor(
                allow=(r'/course/\w+'),
            ),
            callback='parse_item',
            ),
        )

    def parse_item(self, response):
        hxs = HtmlXPathSelector(response)
        edu=EducationalServiceItem()
        #item = EducationalService()
        edu['url']=response.url
        edu['title']=hxs.select('//div[@class="player-head"]/h1/text()').extract()
        objectives=hxs.select('//div[@class="row sum-need-get"]/div[3]/p/span/p[1]/text()').extract()
        if len(objectives)==0:
            objectives=""
            for li in hxs.select('//div[@class="row sum-need-get"]/div[3]/p/span/ul/li/text()').extract():
                objectives+=str(li[0])+"; "
        else:
            objectives=str(objectives[0])
        edu['objectives']=objectives
        hxs.select('//div[@class="row sum-need-get"]/div[3]/p/span/ul/li')
        edu['prereq']=hxs.select('//div[@class="row sum-need-get"]/div[2]/p/span/p[1]/text()').extract()
        edu['summary']=hxs.select('//div[@class="row sum-need-get"]/div[1]/p/span/p[1]/text()').extract()
        edu['teachers']=[]
        instructors=hxs.select("//div[@class='row-fluid']/div/div[@class='inst-bio']")
        for instructor in instructors:
            teacher=TeacherItem()
            teacher['name']=instructor.select("./h5[@class='inst-bio-name']/text()").extract()
            teacher['role']=instructor.select("./h6[@class='inst-bio-title']/text()").extract()
            teacher['bio']=instructor.select("./p/span[@class='pretty-format']/p/text()").extract()
            edu['teachers'].append(teacher)

        return edu

class EdxSpider(CrawlSpider):
    name="edx"
    allowed_domains=["edx.org"]
    start_urls=["https://www.edx.org/courses"]
    # rules = (
    #     Rule(
    #         SgmlLinkExtractor(
    #             allow=('https://www.edx.org/courses/\w+'),
    #         ),
    #         callback='parse_item',
    #         ),
    #     )

    def parse(self, response):
        print response.url
        # links=SgmlLinkExtractor(
        #         allow=('https://www.edx.org/courses/\w+'),
        #     )
        # print "TAMANHO:",len(links.extract_links(response))
        # for link in links.extract_links(response):
        #     request = Request(link.url,callback=self.parse_item)
        #     request.meta['item']=item
        hxs = HtmlXPathSelector(response)
        for li in hxs.select("//ul/li"):
            request = Request("https://www.edx.org"+str(li.select("./article/a/@href").extract()[0]),callback=self.parse_item)
            request.meta['desc']=str(li.select("./article/a/div[1]/section/div[2]/p/text()").extract()[0].encode('utf-8')).strip()
            yield request



    def parse_item(self, response):
        # print response.url
        hxs = HtmlXPathSelector(response)
        edu=EducationalServiceItem()
        title=str(hxs.select('(//h1)[2]/text()').extract()[0])
        edu['title']=title[title.find(":")+2:]
        edu['code']=str(hxs.select('//span[@class="course-number"]/text()').extract()[0])
        edu['url']=response.url
        edu['summary']=response.meta['desc']
        print response.url
        edu['objectives']=""
        first=True
        for child in hxs.select("//section[@class='about']/*"):
            if first:
                first=False
                continue
            
            edu['objectives']+=self.recursiveExtractText(child)
        # print edu['objectives']
        edu['prereq']=""
        first=True
        #Sometimes the class of the section is Prerequisites
        for child in hxs.select("//section[@class='Prerequisites']/*"):
            if first:
                first=False
                continue
            
            edu['prereq']+=self.recursiveExtractText(child)
        first=True
        #Sometimes the class of the section is prerequisites
        for child in hxs.select("//section[@class='prerequisites']/*"):
            if first:
                first=False
                continue
            
            edu['prereq']+=self.recursiveExtractText(child)
        #Sometimes prerequisites are in the box on the right in li tag
        if edu['prereq']=="":
            # open_in_browser(response)
            pre=hxs.select("//li[@class='prerequisites']/span/text()").extract()
            if pre!=[]:
                if not "None" in str(pre[0]):
                    edu['prereq']=str(pre[0].strip())

        # #Teachers
        # for teacher in hxs.select("//section[@class='course-staff']/article|//section[@class='course-staff']/h2/article"):
        #     print teacher.select("./*")[1].select("./text()").extract()
        #     print teacher.select("./p/text()").extract()
        first=True
        edu['teachers']=[]
        teacher=None
        if len(hxs.select("//section[@class='course-staff']/h2/article"))==1:
            for child in hxs.select("//section[@class='course-staff']/h2/article/h3|//section[@class='course-staff']/h2/article/p"):
                if first:
                    if child.select("./text()")==[]:
                        continue
                    first=False
                    teacher=TeacherItem()
                    teacher['name']=str(child.select("./text()").extract()[0].encode('utf-8'))
                    teacher['bio']=""
                else:
                    if child.select("./text()")==[]:
                        first=True
                        edu['teachers'].append(teacher)
                        teacher=None
                    else:
                        teacher['bio']+=str(child.select("./text()").extract()[0].encode('utf-8'))+"\n"
            if teacher!=None:
                edu['teachers'].append(teacher)
        else:
            for teacher in hxs.select("//section[@class='course-staff']/article|//section[@class='course-staff']/h2/article"):
                t=TeacherItem()
                t['name']=str(teacher.select("./*")[1].select("./text()").extract()[0].encode('utf-8'))
                t['bio']=str(teacher.select("./p/text()").extract()[0].encode('utf-8'))
                if not "Berkeley students Nicholas Estorga and Brandon" in t['name']:
                    edu['teachers'].append(t)
        
        return edu


    def recursiveExtractText(self, node):
        if len(node.select("./*"))!=0:
            aux= node.select("./text()").extract()
            text=""
            if len(aux)!=0:
                # print aux[0].strip()
                text=str(aux[0].encode('utf-8')).strip()
            for child in node.select("./*"):
                text+=self.recursiveExtractText(child)+"\n"
            return text
        else:
            if node.select("./text()").extract()!=[]:
                return node.select("./text()").extract()[0].encode('utf-8').strip()
            return ""


class CourseraSpider(CrawlSpider):
    name="coursera"
    # allowed_domains=["https://www.coursera.org","https://www.coursera.org/course"]
    start_urls=["https://www.coursera.org/courses"]
    rules = (
        Rule(
            SgmlLinkExtractor(
                allow=(r'/course/\w+'),
            ),
            callback='parse_item',
            ),
        )
    def parse(self, response):
        print "IN PARSE!"
        # inspect_response(response,self)

        links=SgmlLinkExtractor(
                allow=('https://www.coursera.org/course/\w+'),
            )
        print "TAMANHO:",len(links.extract_links(response))
        for link in links.extract_links(response):
            # print link
            yield Request(link.url,callback=self.parse_item)
        # open_in_browser(response)

    def parse_item(self, response):
        print "IN PARSE_ITEM"
        # open_in_browser(response)
        print response.url
        hxs = HtmlXPathSelector(response)
        edu=EducationalServiceItem()

        edu['url']=response.url
        # if len(hxs.select('//h1/text()').extract())==0:
        #     print "DEU BODE"
        #     print "DEU BODE URL:",response.url
        #     print "DEU BODE BODY:",response.body
        #     open_in_browser(response)
        edu['title']=str(hxs.select('//h1/text()').extract()[0])
        courseDetail=hxs.select('//div[@class="coursera-course-detail"]')

        #In some cases the text is inside a div, in other it isn't
        if courseDetail[0].select('./div/text()').extract()!=[]:
            div=courseDetail[0].select('./div/text()').extract()
        elif courseDetail[0].select('./p/text()').extract()!=[]:
            div=courseDetail[0].select('./p/text()').extract()
        else:
            div=courseDetail[0].select('./text()').extract()

        edu['objectives']=""
        #in some cases the text is spread in <p> tags
        for s in div:
        
            # if aux==[]:
            #     continue
            edu['objectives']+=str(s.strip())
        edu['prereq']=""
        #some courses don't have prerequisites
        if len(courseDetail)>2:
            #In some cases the text is inside a div, in other it isn't
            if courseDetail[2].select('./div/text()').extract()!=[]:
                div=courseDetail[2].select('./div/text()').extract()
            elif courseDetail[2].select('./p/text()').extract()!=[]:
                div=courseDetail[2].select('./p/text()').extract()
            else:
                div=courseDetail[2].select('./text()').extract()
            #in some cases the text is spread in <p> tags
            for s in div:
                # aux=s.select("./text()").extract()
                # if aux==[]:
                #     continue
                edu['prereq']+=str(s.strip())

        # edu['prereq']=str(courseDetail[2].select('./text()').extract()[0])
        edu['summary']=str(hxs.select('(//div[@class="span6"])[1]/p/text()').extract()[0])

        # print "url:",edu['url']
        # print "title:",edu['title']
        # print "objectives:",edu['objectives']
        # print "prereq:",edu['prereq']
        # print "summary:",edu['summary']
        edu['teachers']=[]
        instructors=hxs.select("//div[@class='coursera-course2-instructors']/div")
        for instructor in instructors:
            teacher=TeacherItem()
            teacher['name']=str(instructor.select("./div[3]/a[1]/span/text()").extract()[0])
            # teacher['role']=instructor.select(".//text()").extract()
            teacher['bio']=str(instructor.select("./div[3]/a[2]/span/text()").extract()[0])
            edu['teachers'].append(teacher)

        return edu

class NonioSpider(BaseSpider):
    name = 'nonio'
    start_urls = ['https://inforestudante.uc.pt/nonio/security/init.do']
    allowed_domains = ['inforestudante.uc.pt']

    cursos_domain = "https://inforestudante.uc.pt/nonio/cursos/"
    def parse(self, response):
        print "Gonna send login"
        print response.url
        return [FormRequest.from_response(response,
                    formdata={'method' : 'submeter' ,'username': 'uc2007103732@student.uc.pt', 'password': 'wordPASS0'},
                    callback=self.after_login, dont_filter=True)]
        #dont_filter=True because the login page of NONIO redirects 3 times

    def get_teacher_info(self,response):
        open_in_browser(response)

    def after_login(self, response):
        # check login succeed before going on
        if "Utilizador ou palavra-chave" in response.body:
            print"Login failed"
            return

        # continue scraping with authenticated session...
        # hxs = HtmlXPathSelector(response)
        # div=hxs.select("//div[@id='menu_18']")
        # a=div.select("../@href").extract()[0]
        # print "https://inforestudante.uc.pt/nonio/"+a
        # print "---"
        # b=urlparse.urljoin("https://inforestudante.uc.pt/nonio/", a[1:])
        # print b
        return Request("https://inforestudante.uc.pt/nonio/cursos/init.do?menu=cursos",callback=self.parse_listcourses)

    def parse_listcourses(self, response):
        hxs = HtmlXPathSelector(response)
        table=hxs.select('//table[@class="displaytable"]/tbody/tr/td[last()]')
        # for cell in table:
        #     print self.cursos_domain+str(cell.select("./a/@href").extract()[0])
        #     print "**CALLING**"
        #     yield Request(self.cursos_domain+str(cell.select("./a/@href").extract()[0]),callback=self.parse_course)
        return Request(self.cursos_domain+str(table[6].select("./a/@href").extract()[0]),callback=self.parse_course)

    def parse_course(self, response):
        # open_in_browser(response)
        itemDegree=DegreeItem()
        hxs = HtmlXPathSelector(response)
        td = hxs.select('//td[@class="subtitle"]')
        itemDegree['title']=str(td[0].select('./text()').extract()[0].encode('utf-8')).strip()

        table=hxs.select('//table[@class="zonecontent"]/tr/td')
        
        itemDegree['ects']=str(table[3].select('./text()').extract()[0]).strip()
        itemDegree['acronym']=str(table[1].select('./text()').extract()[0]).strip()
        itemDegree['organization']=str(table[17].select('./text()').extract()[0].encode('utf-8')).strip()
        itemDegree['languages']=str(table[23].select('./text()').extract()[0].encode('utf-8')).strip()
        itemDegree['academicDegree']=str(table[5].select('./text()').extract()[0].encode('utf-8')).strip()
        itemDegree['objectives']=str(table[24].select('./text()').extract()[0].encode('utf-8')).strip()
        #item['duration']
        # item['courseUnits']
        request = Request(self.cursos_domain+str(hxs.select('//div[@id="separators"]/a[2]/@href').extract()[0]),callback=self.parse_unit_list)
        request.meta['item']=itemDegree
        return request

        # print len(table)
        # for t in table:
        #     print t.select('./text()').extract()

    def parse_unit_list(self, response):
        item=response.meta['item']
        item['courseUnits']=[]
        hxs = HtmlXPathSelector(response)
        links=hxs.select('//table[@id="itemActual"]/tbody/tr/td[last()]/a/@href').extract()
        item['size']=len(links)
        for link in links:
            request = Request(self.cursos_domain+str(link),callback=self.parse_unit_editions)
            request.meta['item']=item
            yield request
        # item=response.meta['item']
        # item['courseUnits']="GOT UNIT"
        #str(hxs.select('//a[@id="link_0"]/text()').extract()[0])


    def parse_unit_editions(self, response):
        item=response.meta['item']
        hxs = HtmlXPathSelector(response)
        link = hxs.select('(//table[@class="displaytable"])[1]/tbody/tr[2]/td[last()]/a/@href').extract()
        if len(link)==0:
            item['size']=item['size']-1
        else:
            request = Request(self.cursos_domain+str(link[0]),callback=self.parse_unit)
            request.meta['item']=item
            yield request

        # print str(hxs.select('//table[@class="zonecontent"]/tbody/tr/td[1]/text()').extract()[0].encode("ascii","replace")).strip()
        # item['courseUnits'].append(str(hxs.select('//table[@class="zonecontent"]/tbody/tr/td[1]/text()').extract()[0].encode("ascii","replace")).strip())

    def parse_unit(self, response):
        
        item=response.meta['item']
        hxs = HtmlXPathSelector(response)
        table=hxs.select('(//table[@class="zonecontent"])[1]/tr/td')
        unitItem=UnitItem()
        unitItem['ects']=str(table[15].select('./text()').extract()[0]).strip()
        unitItem['semester']=str(table[7].select('./text()').extract()[0].encode('utf-8')).strip()
        unitItem['title']=str(table[1].select('./text()').extract()[0].encode('utf-8')).strip()
        unitItem['language']=str(table[13].select('./text()').extract()[0].encode('utf-8')).strip()
        unitItem['deliverymode']=str(table[19].select('./text()').extract()[0].encode('utf-8')).strip()
        # print unitItem['title']
        # print unitItem['deliverymode']
        unitItem['teachers']=str(table[9].select('./text()').extract()[0].encode('utf-8')).strip()
        unitItem['url']=response.url
        table=hxs.select('(//table[@class="zonecontent"])[2]/tr/td')
        # test=""
        # for td in table:
        #     #All the information is inside this td variable
        #     #However, some is inside <div> or <p> or <br>
        #     #So we must check if the td has descendants, if not we extract the text
        #     #if yes we go through the childs and extract the childs text no matter what they are
        #     #in the end we check if some text was added by the aux variable, if not it means that the
        #     #<br> is in between
        #     if len(td.select('./descendant::*'))==0:
        #         test+=str(td.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #     else:
        #         aux=0
        #         for des in td.select('./descendant::*'):
        #             if len(des.select('./text()'))>0:
        #                 test+=str(des.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #                 aux=1
        #         if aux==0:
        #             for s in td.select('./text()').extract():
        #                 test+=str(s.encode('utf-8')).strip()+" "
        # print "OLD ALGORITHM OBJECTIVE:",test
        test=""
        test+=self.recursiveExtractText(table)
        # print "NEW ALGORITHM OBJECTIVE:",test2
        unitItem['objectives']=test
        # if "Bases de Dados" in test2:
        #     inspect_response(response)        
        table=hxs.select('(//table[@class="zonecontent"])[6]/tr/td')
        # test=""
        # for td in table:
        #     #All the information is inside this td variable
        #     #However, some is inside <div> or <p> or <br> or nothing
        #     #So we must check if the td has descendants, if not we extract the text
        #     #if yes we go through the childs and extract the childs text no matter what they are
        #     #in the end we check if some text was added by the aux variable, if not it means that the
        #     #<br> is in between
        #     if len(td.select('./descendant::*'))==0:
        #         test+=str(td.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #     else:
        #         aux=0
        #         for des in td.select('./descendant::*'):
        #             if len(des.select('./text()'))>0:
        #                 test+=str(des.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #                 aux=1
        #         if aux==0:
        #             for s in td.select('./text()').extract():
        #                 test+=str(s.encode('utf-8')).strip()+" "
        test=""
        test+=self.recursiveExtractText(table)
        unitItem['prereq']=test
        table=hxs.select('(//table[@class="zonecontent"])[4]/tr/td')
        # test=""
        # for td in table:
        #     #All the information is inside this td variable
        #     #However, some is inside <div> or <p> or <br> or nothing
        #     #So we must check if the td has descendants, if not we extract the text
        #     #if yes we go through the childs and extract the childs text no matter what they are
        #     #in the end we check if some text was added by the aux variable, if not it means that the
        #     #<br> is in between
        #     if len(td.select('./descendant::*'))==0:
        #         test+=str(td.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #     else:
        #         aux=0
        #         for des in td.select('./descendant::*'):
        #             if len(des.select('./text()'))>0:
        #                 test+=str(des.select('./text()').extract()[0].encode('utf-8')).strip()+" "
        #                 aux=1
        #         if aux==0:
        #             for s in td.select('./text()').extract():
        #                 test+=str(s.encode('utf-8')).strip()+" "
        test=""
        test+=self.recursiveExtractText(table)
        unitItem['summary']=test
        item['courseUnits'].append(unitItem)
        return item

    def recursiveExtractText(self, node):
        if len(node.select("./*"))!=0:
            aux= node.select("./text()").extract()
            text=""
            # if len(aux)!=0:
            #     # print aux[0].strip()
            #     text=str(aux[0].encode('utf-8')).strip()
            pos=0
            for child in node.select("./*"):
                if pos<len(aux):
                    text+=" "+str(aux[pos].encode('utf-8')).strip()
                text+=" "+self.recursiveExtractText(child)
                pos+=1
            for pos in range(pos,len(aux)):
                text+=" "+str(aux[pos].encode('utf-8')).strip()
            return text
        else:
            if node.select("./text()").extract()!=[]:
                return node.select("./text()").extract()[0].encode('utf-8').strip()
            return ""
        

class GenSpider(BaseSpider):
    name = 'gen'
    start_urls = ['http://rdf.genssiz.dei.uc.pt/user']
    allowed_domains = ['rdf.genssiz.dei.uc.pt']

    def parse(self, response):
        print response.url
        return [FormRequest.from_response(response,
                    formdata={'name': 'jduro', 'pass': 'admin'},
                    callback=self.after_login)]

    def after_login(self, response):
        print "GOT HERE"
        # check login succeed before going on
        if "Sorry" in response.body:
            print"Login failed"
            return
        if "My account" in response.body:
            print "YES!"


        # continue scraping with authenticated session...

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