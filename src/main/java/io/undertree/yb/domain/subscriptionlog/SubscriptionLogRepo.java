package io.undertree.yb.domain.subscriptionlog;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SubscriptionLogRepo extends JpaRepository<SubscriptionLog, Long> {
    Optional<SubscriptionLog> findByPartnerId(String partnerId);
}
