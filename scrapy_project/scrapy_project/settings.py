# Scrapy settings for scrapy_project project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/topics/settings.html
#

BOT_NAME = 'scrapy_project'

SPIDER_MODULES = ['scrapy_project.spiders']
NEWSPIDER_MODULE = 'scrapy_project.spiders'

ITEM_PIPELINES = ['scrapy_project.pipelines.ScrapyProjectPipeline']

DOWNLOADER_MIDDLEWARES = {'scrapy_project.middlewares.WebkitDownloader': 3333,}

# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'scrapy_project (+http://www.yourdomain.com)'
