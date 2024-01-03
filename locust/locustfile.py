from locust import HttpUser, task, between, tag
import random
import json

class LoadSimulator(HttpUser):
    wait_time = between(0.5, 2)

    @task
    @tag('userByEmail')
    def get_user_by_email(self):
        num = between(1, 600000)
        self.client.get(f"/api/user/users?email=foo{num}@bar.com", name="/user/users?email=?")

    @task
    @tag('createNotifyLog')
    def post_notify_log(self):
        self.client.post(f"/api/notify/log")

    @task
    @tag('checkDevices')
    def do_device_check(self):
        self.client.get(f"/api/devices/", name="/devices/")

    @task
    @tag('deviceTracker2')
    def patch_device_tracker2(self):
        num = random.randint(1, 11000)
        num2 = random.randint(1, 60)
        d1 = 'cdd7cacd-8e0a-4372-8ceb-' + str(num).zfill(12)
        d2 = '48d1c2c2-0d83-43d9-' + str(num2).zfill(4) + '-' + str(num).zfill(12)
        m = 'MOD-' + str(random.randint(0, 4))
        jsond = {
            'deviceId': d1,
            'mediaId': d2,
            'status': m
        }
        self.client.patch(f"/api/tracker/batch", data=json.dumps(jsond), headers={'Content-Type': 'application/json', 'Accept': 'application/json'})

    @task
    @tag('deviceTracker3')
    def patch_device_tracker3(self):
        batch_size = 100
        self.client.post(f"/api/tracker/{batch_size}")

    @task
    @tag('refreshToken')
    def post_token(self):
        self.client.post(f"/api/token?rand=100")

    @task
    @tag('refreshToken3')
    def post_token3(self):
        self.client.post(f"/api/tokens?rand=1000")
