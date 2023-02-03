package io.undertree.yb.hibernate;

import org.hibernate.boot.model.naming.Identifier;
import org.hibernate.boot.model.relational.QualifiedName;
import org.hibernate.boot.model.relational.QualifiedNameParser;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.dialect.Dialect;
import org.hibernate.engine.config.spi.ConfigurationService;
import org.hibernate.engine.config.spi.StandardConverters;
import org.hibernate.engine.jdbc.env.spi.JdbcEnvironment;
import org.hibernate.id.IdentifierGenerator;
import org.hibernate.id.enhanced.SequenceStyleGenerator;
import org.hibernate.internal.util.StringHelper;
import org.hibernate.internal.util.config.ConfigurationHelper;
import org.hibernate.service.ServiceRegistry;

import java.util.Properties;
import java.util.Random;

/**
 * TODO WIP on creating a custom Sequence Generator that can span multiple sequences
 */
public class YugabyteSequenceGenerator extends SequenceStyleGenerator {

    public static final String SEQUENCE_MAX_BUCKETS = "sequence_max_buckets";

    /**
     * Determine the name of the sequence (or table if this resolves to a physical table)
     * to use.
     * <p/>
     * Called during {@link #configure configuration}.
     *
     * @param params  The params supplied in the generator config (plus some standard useful extras).
     * @param dialect The dialect in effect
     * @param jdbcEnv The JdbcEnvironment
     * @return The sequence name
     */
    @SuppressWarnings({"UnusedParameters", "WeakerAccess"})
    @Override
    protected QualifiedName determineSequenceName(
            Properties params,
            Dialect dialect,
            JdbcEnvironment jdbcEnv,
            ServiceRegistry serviceRegistry) {
        final String sequencePerEntitySuffix = ConfigurationHelper.getString(CONFIG_SEQUENCE_PER_ENTITY_SUFFIX, params, DEF_SEQUENCE_SUFFIX);

        String fallbackSequenceName = DEF_SEQUENCE_NAME;
        final Boolean preferGeneratorNameAsDefaultName = serviceRegistry.getService(ConfigurationService.class)
                .getSetting(AvailableSettings.PREFER_GENERATOR_NAME_AS_DEFAULT_SEQUENCE_NAME, StandardConverters.BOOLEAN, true);
        if (preferGeneratorNameAsDefaultName) {
            final String generatorName = params.getProperty(IdentifierGenerator.GENERATOR_NAME);
            if (StringHelper.isNotEmpty(generatorName)) {
                fallbackSequenceName = generatorName;
            }
        }

        // JPA_ENTITY_NAME value honors <class ... entity-name="..."> (HBM) and @Entity#name (JPA) overrides.
        final String defaultSequenceName = ConfigurationHelper.getBoolean(CONFIG_PREFER_SEQUENCE_PER_ENTITY, params, false)
                ? params.getProperty(JPA_ENTITY_NAME) + sequencePerEntitySuffix
                : fallbackSequenceName;

        String sequenceName = ConfigurationHelper.getString(SEQUENCE_PARAM, params, defaultSequenceName);

        final int maxSequenceBuckets = ConfigurationHelper.getInt(SEQUENCE_MAX_BUCKETS, params, 0);

        // if maxSequenceBuckets > 0 then update the sequence name using a random bucket from 0-maxSequenceBuckets
        if (maxSequenceBuckets > 0) {
            Random rand = new Random();
            // assumes the sequenceName has a %d in the string itself to replace with the bucket number
            sequenceName = String.format(sequenceName, rand.nextInt(maxSequenceBuckets));
        }

        if (sequenceName.contains(".")) {
            return QualifiedNameParser.INSTANCE.parse(sequenceName);
        } else {
            // todo : need to incorporate implicit catalog and schema names
            final Identifier catalog = jdbcEnv.getIdentifierHelper().toIdentifier(
                    ConfigurationHelper.getString(CATALOG, params)
            );
            final Identifier schema = jdbcEnv.getIdentifierHelper().toIdentifier(
                    ConfigurationHelper.getString(SCHEMA, params)
            );
            return new QualifiedNameParser.NameParts(
                    catalog,
                    schema,
                    jdbcEnv.getIdentifierHelper().toIdentifier(sequenceName)
            );
        }
    }
}
