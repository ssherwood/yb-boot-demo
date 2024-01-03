package io.undertree.yb.domain.account;

import java.util.Map;

public record CreateAccountDto(
        String email,
        Map<String, Object> details) {
}