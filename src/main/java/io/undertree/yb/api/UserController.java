package io.undertree.yb.api;

import io.undertree.yb.domain.user.User;
import io.undertree.yb.domain.user.UserRepo;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserRepo userRepo;

    public UserController(UserRepo userRepo) {
        this.userRepo = userRepo;
    }

    @GetMapping("/users")
    public Optional<User> findByEmail(@RequestParam String email) {
        return userRepo.findByEmail(email);
    }

    @PostMapping("/users")
    public User findByEmail(@RequestBody User user) {
        return userRepo.save(user);
    }
}