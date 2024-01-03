package io.undertree.yb.domain.user;

import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.QueryHints;

import java.util.Optional;

import static org.hibernate.annotations.QueryHints.COMMENT;

public interface UserRepoEast extends JpaRepository<User, Long> {
//    @QueryHints({
//            // using regional index to improve performance of local lookups
//            @QueryHint(name = COMMENT, value = "+IndexOnlyScan(u1_0 geo_email_east1)")
//    })
    Optional<User> findByEmail(String email);
}
