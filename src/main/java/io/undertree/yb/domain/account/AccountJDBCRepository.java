package io.undertree.yb.domain.account;

import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Repository
public class AccountJDBCRepository {
    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final AccountDtoMapper accountDtoMapper;

    private static final String FIND_BY_ID = "SELECT * FROM account WHERE id = :id";
    private static final String INSERT_ONE = "INSERT INTO account (email, details) VALUES (:email, :details)";

    public AccountJDBCRepository(NamedParameterJdbcTemplate jdbcTemplate, AccountDtoMapper accountDtoMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.accountDtoMapper = accountDtoMapper;
    }

    public AccountDto save(CreateAccountDto createAccountDto) {
        try {
            var keyHolder = new GeneratedKeyHolder();
            var rowsAffected = jdbcTemplate.update(INSERT_ONE, accountDtoMapper.toParams(createAccountDto), keyHolder);
            return accountDtoMapper.fromKeyHolder(keyHolder);
        } catch (SQLException sqlException) {
            throw new InvalidDataAccessResourceUsageException(sqlException.getMessage());
        }
    }

    /**
     * Finds an account by its ID.
     *
     * @param id The ID of the account to find.
     * @return An {@code Optional} containing the account if it was found, or an empty {@code Optional} if it was not found.
     */
    public Optional<AccountDto> findOneById(UUID id) {
        var accountDto = jdbcTemplate.queryForObject(FIND_BY_ID, Map.of("id", id), accountDtoMapper);
        return Optional.ofNullable(accountDto);
    }
}
