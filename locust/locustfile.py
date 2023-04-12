from locust import HttpUser, task, between, tag


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
