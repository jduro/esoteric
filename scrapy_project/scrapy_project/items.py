# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/topics/items.html

from scrapy.item import Item, Field

class ScrapyProjectItem(Item):
    # define the fields for your item here like:
    # name = Field()
    pass

class DmozItem(Item):
    title = Field()
    link = Field()
    desc = Field()

class EducationalService(Item):
	title = Field()
	summary = Field()
	prereq = Field()
	objectives = Field()
	teachers = Field()

class ContextItem(Item):
    title = Field()
    subContext = Field()