package io.undertree.yb.api;

import io.undertree.yb.domain.user.User;
import io.undertree.yb.domain.user.UserRepoCentral;
import io.undertree.yb.domain.user.UserRepoEast;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserRepoEast userRepoEast;
    private final UserRepoCentral userRepoCentral;

    public UserController(UserRepoEast userRepoEast, UserRepoCentral userRepoCentral) {
        this.userRepoEast = userRepoEast;
        this.userRepoCentral = userRepoCentral;
    }

    @GetMapping("/users")
    public Optional<User> findByEmail(@RequestParam String email) {
        return userRepoEast.findByEmail(email);
    }

    @PostMapping("/users")
    public User findByEmail(@RequestBody User user) {
        return userRepoEast.save(user);
    }
}