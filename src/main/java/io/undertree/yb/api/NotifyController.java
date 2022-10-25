package io.undertree.yb.api;

import io.undertree.yb.domain.NotifyLog;
import io.undertree.yb.domain.NotifyLogService;
import io.undertree.yb.domain.NotifyLogUUID;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.RandomUtils;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.query.Query;
import org.springframework.web.bind.annotation.*;

import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
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

//        Session session = entityManagerFactory.unwrap(Session.class);
//        Query q = session.createNativeQuery("SET enable_nestloop TO off");
//        q.addQueryHint("")

        String foo = "/*+ */";
        Optional<NotifyLog> results = notifyLogService.findById(id);

        //session.createNativeQuery("SET enable_nestloop TO on").executeUpdate();

        return results;
    }

    @PostMapping("/log")
    public NotifyLog addRecurlyNotifyLog(NotifyLog notifyLog) {
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
    public NotifyLogUUID addRecurlyNotifyLogUUID(NotifyLogUUID notifyLogUUID) {
        var record = new NotifyLogUUID();
        record.setIngestDate(Date.from(Instant.now()));
        record.setNotification(RandomStringUtils.randomAlphabetic(255));
        record.setSubscriptionId(RandomStringUtils.randomAlphanumeric(255));
        record.setUserId(RandomUtils.nextLong());
        return notifyLogService.insertNotifyLogUUID(record);
    }

}
