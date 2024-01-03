package io.undertree.yb.domain.tokens;

import java.time.OffsetDateTime;
import java.util.UUID;

public record RefreshToken(UUID token, UUID accountId, OffsetDateTime createdAt, OffsetDateTime validUntil,
                           String code) {
}