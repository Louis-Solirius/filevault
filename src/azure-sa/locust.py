import time
from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    waitTime = between(1, 5)

    @task
    def indexPage(self):
        self.client.get(url="")

    @task
    def filesPage(self):
        self.client.get(url="/files")

