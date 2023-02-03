package io.undertree.yb.hibernate;

import org.hibernate.dialect.PostgreSQL10Dialect;
import org.hibernate.engine.spi.QueryParameters;

/**
 *
 */
public class YugabyteDialect extends PostgreSQL10Dialect {

    @Override
    public String addSqlHintOrComment(String sql, QueryParameters parameters, boolean commentsEnabled) {
        if (parameters.getQueryHints() != null && parameters.getQueryHints().size() > 0) {
            sql = this.getQueryHintString(sql, parameters.getQueryHints());
        }

        if (parameters.getComment() != null) {
            if (parameters.getComment().startsWith("+")) {
                // custom check if the comment looks like a special database hint...
                // this also does not require comments to be enabled
                sql = "/*" + parameters.getComment() + "*/ " + sql;
            } else if (commentsEnabled) {
                sql = this.prependComment(sql, parameters.getComment());
            }
        }

        return sql;
    }
}
