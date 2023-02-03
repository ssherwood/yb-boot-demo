from locust import HttpUser, task, between, tag


class LoadSimulator(HttpUser):
    wait_time = between(0.5, 5)

    @task
    @tag('userByEmail')
    def get_user_by_email(self):
        num = between(1, 600000)
        self.client.get(f"/api/user/users?email=foo{num}@bar.com", name="/user/users?email=?")
