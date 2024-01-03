package io.undertree.yb.domain.account;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.Map;
import java.util.UUID;

@Component
public class AccountDtoMapper implements RowMapper<AccountDto> {
    private static final TypeReference<Map<String, Object>> JSON_AS_MAP = new TypeReference<>() {
    };

    private final ObjectMapper objectMapper;

    public AccountDtoMapper(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    /**
     * Maps the results of a KeyHolder to a realised Account object.
     * This assumes the underlying database returns all columns in the KeyHolder
     * (which appears to be true for YugabyteDB and PostgresSQL).
     *
     * Also requires PreparedStatementCreatorFactory.setReturnGeneratedKeys(true)
     *
     * @param keyHolder
     * @return
     * @throws SQLException
     * @see org.springframework.jdbc.support.KeyHolder
     */
    public AccountDto fromKeyHolder(KeyHolder keyHolder) throws SQLException {
        try {
            var keyValues = keyHolder.getKeys();
            if (keyValues != null && keyValues.size() > 0) {
                return new AccountDto(
                        (UUID) keyValues.get("id"),
                        (String) keyValues.get("email"),
                        objectMapper.readValue(keyValues.get("details").toString(), JSON_AS_MAP),
                        ((Timestamp) keyValues.get("created_at")).toInstant(),
                        ((Timestamp) keyValues.get("updated_at")).toInstant()
                );
            } else {
                throw new SQLException("KeyHolder getKeys was null or empty.");
            }
        } catch (JsonProcessingException e) {
            throw new SQLException("Unable to map KeyHolder results to Account", e);
        }
    }

    public MapSqlParameterSource toParams(CreateAccountDto accountDto) throws SQLException {
        try {
            return new MapSqlParameterSource()
                    .addValue("email", accountDto.email())
                    .addValue("details", objectMapper.writeValueAsString(accountDto.details()), Types.OTHER);
        } catch (JsonProcessingException e) {
            throw new SQLException(e);
        }
    }

    @Override
    public AccountDto mapRow(ResultSet rs, int rowNum) throws SQLException {
        try {
            return new AccountDto(
                    rs.getObject("id", UUID.class),
                    rs.getString("email"),
                    objectMapper.readValue(rs.getString("details"), JSON_AS_MAP),
                    rs.getTimestamp("created_at").toInstant(),
                    rs.getTimestamp("updated_at").toInstant()
            );
        } catch (JsonProcessingException e) {
            throw new SQLException(e);
        }
    }
}
