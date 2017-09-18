import os
import sys
import time
import requests
import logging
import logging.handlers
from lxml import html
from locust import HttpLocust, TaskSet, task


# ====================================================================================
# Logging
# ------------------------------------------------------------------------------------
LOG_FILENAME = "/tmp/download-agent.log"
LOG_LEVEL = logging.INFO  # Could be e.g. "DEBUG" or "WARNING"

# Configure logging to log to a file, making a new file at midnight and keeping the last 3 day's data
# Give the logger a unique name (good practice)
logger = logging.getLogger(__name__)
# Set the log level to LOG_LEVEL
logger.setLevel(LOG_LEVEL)
# Make a handler that writes to a file, making a new file at midnight and keeping 3 backups
handler = logging.handlers.TimedRotatingFileHandler(LOG_FILENAME, when="midnight", backupCount=3)
# Format each log message like this
formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
# Attach the formatter to the handler
handler.setFormatter(formatter)
# Attach the handler to the logger
logger.addHandler(handler)

class UserBehavior(TaskSet):
    def on_start(self):
        self.login()
    def login(self):
        try:
            login_page = self.client.get('/login')
            tree = html.fromstring(login_page.content)
            csrf_token = tree.xpath('//input[@name="signin[_csrf_token]"]/@value')
            payload = {
                'signin[_csrf_token]': csrf_token[0],
                'signin[username]': 'siwapp',
                'signin[password]': 'siwapp'
            }
            self.client.post('/login',data=payload)
        except:
            logger.error("Error logging into server")
            pass       
    @task(1)
    def dashboard(self):
        self.client.get('/dashboard')
    @task(2)
    def invoices(self):
        self.client.get('/invoices')
    @task(3)
    def recurring(self):
        self.client.get('/recurring')
    @task(4)
    def customers(self):
        self.client.get('/customers')
    @task(5)
    def estimates(self):
        self.client.get('/estimates')
    @task(6)
    def products(self):
        self.client.get('/products')
    '''@task(7)
    def logout(self):
        self.client.get('/logout')
        cookies = self.client.cookies.get_dict()
        logger.info("Successfully hit all pages for Server: " + cookies['SERVERID'])'''

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000
