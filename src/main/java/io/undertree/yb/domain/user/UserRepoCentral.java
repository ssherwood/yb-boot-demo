package io.undertree.yb.domain.user;

import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.QueryHints;

import java.util.Optional;

import static org.hibernate.annotations.QueryHints.COMMENT;

public interface UserRepoCentral extends JpaRepository<User, Long> {
    @QueryHints({
            @QueryHint(name = COMMENT, value = "+IndexOnlyScan(yb_user email_cover_central)")
    })
    Optional<User> findByEmail(String email);
}