from scrapy.http import Request, FormRequest, HtmlResponse

import time
from selenium import selenium
from selenium import webdriver

class WebkitDownloader( object ):
    def process_request( self, request, spider ):
        if( type(request) is not FormRequest and spider.name=="coursera"):
            # print "Entered Downloader for:",request.url
            self.selenium = webdriver.Firefox()
            #webdriver rendered page
            sel = self.selenium
            sel.get(request.url)

            if sel:
            	#Wait for javascript to load in Selenium
                if request.url=="https://www.coursera.org/courses":
                    print "[50]Entered Downloader for:",request.url
                    time.sleep(50)
                else:
                    print "[10]Entered Downloader for:",request.url
                    time.sleep(10)

            renderedBody = str(sel.page_source.encode("ascii", "ignore"))
            sel.quit()
            return HtmlResponse( request.url, body=renderedBody )