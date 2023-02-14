package io.undertree.yb.domain.subscriptionlog;

import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.Instant;
import java.util.Optional;

@Service
public class SubscriptionLogService {
    private final SubscriptionLogRepo subscriptionLogRepo;

    public SubscriptionLogService(SubscriptionLogRepo subscriptionLogRepo) {
        this.subscriptionLogRepo = subscriptionLogRepo;
    }

    //@Transactional
    public SubscriptionLog saveOrUpdateSubscriptionLog(SubscriptionLog subscriptionLog) {
        Optional<SubscriptionLog> userSubscription = subscriptionLogRepo.findFirstByExternalSubscriptionId(subscriptionLog.getExternalSubscriptionId());

        if (userSubscription.isEmpty()) {
            subscriptionLog.setCreatedDate(Date.from(Instant.now()));
            subscriptionLog.setUpdatedDate(Date.from(Instant.now()));
            return subscriptionLogRepo.save(subscriptionLog);
        } else {
            var oldSubscriptionLog = userSubscription.get();
            if (oldSubscriptionLog.getRegistrationStatus() != subscriptionLog.getRegistrationStatus()) {
                oldSubscriptionLog.setRegistrationStatus(subscriptionLog.getRegistrationStatus());
                oldSubscriptionLog.setUpdatedDate(Date.from(Instant.now()));
                return subscriptionLogRepo.save(oldSubscriptionLog);
            } else {
                // ignore update
                return oldSubscriptionLog;
            }
        }
    }
}
