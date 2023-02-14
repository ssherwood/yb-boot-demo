package io.undertree.yb.domain.subscriptionlog;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

public interface SubscriptionLogRepo extends JpaRepository<SubscriptionLog, Long> {
    Optional<SubscriptionLog> findByPartnerId(String partnerId);

    @Transactional(readOnly = true)
    Optional<SubscriptionLog> findFirstByExternalSubscriptionId(String externalSubscriptionId);
}
