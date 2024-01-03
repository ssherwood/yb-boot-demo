package io.undertree.yb.api;

import io.undertree.yb.domain.tokens.RefreshToken;
import io.undertree.yb.domain.tokens.RefreshTokenRepo;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/token")
public class RefreshTokenController {
    private final RefreshTokenRepo refreshTokenRepo;
    private final Random random = new Random();

    public RefreshTokenController(RefreshTokenRepo refreshTokenRepo) {
        this.refreshTokenRepo = refreshTokenRepo;
    }

    @PostMapping()
    public RefreshToken insertOrUpdateOne(@RequestParam(defaultValue = "1000000") int rand) {
        var id = random.nextInt(rand);
        var token = new RefreshToken(randomToken(id), randomAccountId(id), OffsetDateTime.now(), OffsetDateTime.now().plusDays(10), randomBrandCode());

        if (refreshTokenRepo.insertOrUpdate(token) > 0) {
            return token;
        }
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "400 BAD REQUEST: ");
    }

    public UUID randomToken(int id) {
        return UUID.fromString(String.format("00000000-0000-0000-0000-%012d", id));
    }

    public UUID randomAccountId(int id) {
        return UUID.fromString(String.format("12345678-1234-1234-1234-%012d", id));
    }

    public String randomBrandCode() {
        return String.format("Brand-%d", random.nextInt(100));
    }
}
