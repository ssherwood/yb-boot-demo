package io.undertree.yb.domain.tokens;

import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RefreshTokenRepo {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    public RefreshTokenRepo(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public int insertOrUpdate(RefreshToken refreshToken) {
        var query = """
                INSERT INTO yb_token_refresh(token, account_id, created_at, valid_until, code)
                VALUES(:token, :accountId, :createdAt, :validUntil, :code)
                ON CONFLICT (token) DO UPDATE
                    SET account_id = EXCLUDED.account_id,
                    valid_until = EXCLUDED.valid_until,
                    code = EXCLUDED.code
                """;

        var props = new BeanPropertySqlParameterSource(refreshToken);
        return jdbcTemplate.update(query, props);
    }
}
