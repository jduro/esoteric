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

class EducationalServiceItem(Item):
    title = Field()
    objectives = Field()
    prereq = Field()
    summary = Field()
    teachers = Field()
    url = Field()

class DegreeItem(Item):
    size = Field()
    title = Field()
    ects = Field()
    acronym = Field()
    organization = Field()
    languages = Field()
    objectives = Field()
    courseUnits = Field()
    academicDegree = Field()
    duration = Field()

class UnitItem(Item):
    summary = Field()
    ects = Field()
    semester = Field()
    objectives = Field()
    title = Field()
    workload = Field()
    teachers = Field()
    language = Field()
    prereq = Field()
    deliverymode = Field()
    url = Field()

class TeacherItem(Item):
    name = Field()
    role = Field()
    bio = Field()

class ContextItem(Item):
    title = Field()
    subContext = Field()

class StbItem(Item):
    JD = Field()