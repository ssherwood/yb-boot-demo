package io.undertree.yb.domain.account;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record AccountDto(
        UUID id,
        String email,
        Map<String, Object> details,
        Instant createdAt,
        Instant updatedAt) {
}