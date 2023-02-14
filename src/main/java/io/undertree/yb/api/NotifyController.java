package io.undertree.yb.api;

import io.undertree.yb.domain.notifylog.NotifyLog;
import io.undertree.yb.domain.notifylog.NotifyLogService;
import io.undertree.yb.domain.notifylog.NotifyLogUUID;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.PersistenceUnit;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.hibernate.SessionFactory;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/notify")
public class NotifyController {

    @PersistenceUnit
    EntityManagerFactory entityManagerFactory;

    private final NotifyLogService notifyLogService;

    public NotifyController(NotifyLogService notifyLogService) {
        this.notifyLogService = notifyLogService;
    }

    @GetMapping("/log/{id}")
    public Optional<NotifyLog> findLog(@PathVariable Long id) {
        SessionFactory sessionFactory = entityManagerFactory.unwrap(SessionFactory.class);
        System.out.println(sessionFactory.getSessionFactoryOptions().getPhysicalConnectionHandlingMode());

// Local – the set command using local will take effect only the current transaction which we have running.
// After commit or rollback it will not take effect again, we need set is again.
// see https://www.postgresql.org/docs/8.0/runtime-config.html

//        Session session = entityManagerFactory.unwrap(Session.class);
//        Query q = session.createNativeQuery("SET LOCAL enable_nestloop TO off");
//        q.addQueryHint("")

        Optional<NotifyLog> results = notifyLogService.findById(id);

        //session.createNativeQuery("SET LOCAL enable_nestloop TO on").executeUpdate();

        return results;
    }

    @PostMapping("/log")
    public NotifyLog addNotifyLog(NotifyLog notifyLog) {
        var record = new NotifyLog();
        record.setIngestDate(Date.from(Instant.now()));
        record.setNotification(RandomStringUtils.randomAlphabetic(255));
        record.setSubscriptionId(RandomStringUtils.randomAlphanumeric(255));
        record.setUserId(RandomUtils.nextLong());
        return notifyLogService.insertNotifyLog(record);
    }

    @GetMapping("/log-uuid/{id}")
    public Optional<NotifyLogUUID> findLogUUID(@PathVariable UUID id) {
        return notifyLogService.findById(id);
    }

    @PostMapping("/log-uuid")
    public NotifyLogUUID addNotifyLogUUID(NotifyLogUUID notifyLogUUID) {
        var record = new NotifyLogUUID();
        record.setIngestDate(Date.from(Instant.now()));
        record.setNotification(RandomStringUtils.randomAlphabetic(255));
        record.setSubscriptionId(RandomStringUtils.randomAlphanumeric(255));
        record.setUserId(RandomUtils.nextLong());
        return notifyLogService.insertNotifyLogUUID(record);
    }
}
