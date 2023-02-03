package io.undertree.yb.domain.notifylog;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;

import javax.persistence.QueryHint;
import java.util.Optional;

public interface YBNotifyLogRepo extends JpaRepository<NotifyLog, Long> {

    @Modifying
    @Query(nativeQuery = true, value = "SET LOCAL enable_nestloop TO off")
    void disableNestedLoop();

    @Modifying
    @Query(nativeQuery = true, value = "SET LOCAL enable_nestloop TO on")
    void enableNestedLoop();

    //@Override
    @Query(value = "FROM NotifyLog WHERE id = ?1")
    //@NamedQuery(name="foo", query = "FROM NotifyLog WHERE id = ?1", hints = @QueryHint(name = org.hibernate.annotations.QueryHints.COMMENT, value = "Set(enable_nestloop off)"))
    //@Query(value = "/*+Set(enable_nestloop off)*/", nativeQuery = true) <- you can do it in a native query
    @QueryHints({
            //@QueryHint(name = "disableNestLoop", value = "Set(enable_nestloop off)")
            @QueryHint(name = org.hibernate.annotations.QueryHints.COMMENT, value = "+Set(enable_nestloop off)")
            // ^ this doesn't work, requires comments enabled but puts a space between the '/*' and the '+'
    })
    Optional<NotifyLog> finder(Long id);
}
