package io.undertree.yb.hibernate;

import org.hibernate.boot.model.relational.QualifiedName;
import org.hibernate.dialect.Dialect;
import org.hibernate.engine.jdbc.env.spi.JdbcEnvironment;
import org.hibernate.id.enhanced.SequenceStyleGenerator;
import org.hibernate.service.ServiceRegistry;

import java.util.Properties;

/**
 * TODO WIP on creating a custom Sequence Generator that can span multiple sequences
 * and, in theory, improving concurrent nextval + insert use cases...
 */
public class YugabyteSequenceGenerator extends SequenceStyleGenerator {
    @Override
    protected QualifiedName determineSequenceName(Properties params,
                                                  Dialect dialect,
                                                  JdbcEnvironment jdbcEnv,
                                                  ServiceRegistry serviceRegistry) {
        return null;
    }
}
