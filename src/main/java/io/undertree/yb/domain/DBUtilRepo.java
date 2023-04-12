package io.undertree.yb.domain;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class DBUtilRepo {
    private final JdbcTemplate jdbcTemplate;

    public DBUtilRepo(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void disableNestedLoop() {
        jdbcTemplate.update("SET LOCAL enable_nestloop TO off");
    }

    public void enableNestedLoop() {
        jdbcTemplate.update("SET LOCAL enable_nestloop TO on");
    }

    public void disableSeqScan() {
        jdbcTemplate.update("SET LOCAL enable_seqscan TO off");
    }

    public void enableSeqScan() {
        jdbcTemplate.update("SET LOCAL enable_seqscan TO on");
    }
}
