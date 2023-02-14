package io.undertree.yb.hibernate;


import org.hibernate.dialect.PostgreSQLDialect;
import org.hibernate.query.spi.QueryOptions;

/**
 * YugabyteDialect
 */
public class YugabyteDialect extends PostgreSQLDialect {

    static final String HINT_INDICATOR = "+";
    static final String HINT_PREFIX = "/*";
    static final String HINT_SUFFIX = "*/";

    /**
     * Modify the SQL, adding hints or comments, if necessary
     */
    public String addSqlHintOrComment(
            String sql,
            QueryOptions queryOptions,
            boolean commentsEnabled) {
        // Keep this here, rather than moving to Select.  Some Dialects may need the hint to be appended to the very
        // end or beginning of the finalized SQL statement, so wait until everything is processed.
        if (queryOptions.getDatabaseHints() != null && queryOptions.getDatabaseHints().size() > 0) {
            sql = getQueryHintString(sql, queryOptions.getDatabaseHints());
        }
        // For YugabyteDB, inject the hint from comment if it starts with a + (ignoring the whole idea of comments
        // being enabled).
        if (queryOptions.getComment() != null) {
            if (queryOptions.getComment().startsWith(HINT_INDICATOR)) {
                sql = HINT_PREFIX + queryOptions.getComment() + HINT_SUFFIX + sql;
            } else if (commentsEnabled) {
                sql = this.prependComment(sql, queryOptions.getComment());
            }
        }

        return sql;
    }
}
