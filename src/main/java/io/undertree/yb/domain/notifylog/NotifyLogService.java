package io.undertree.yb.domain.notifylog;

import io.undertree.yb.domain.DBUtilRepo;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.Optional;
import java.util.UUID;

@Service
public class NotifyLogService {
    private final YBNotifyLogRepo notifyLogRepo;
    private final NotifyLogUUIDRepo notifyLogUUIDRepo;
    private final DBUtilRepo dbUtilRepo;

    public NotifyLogService(YBNotifyLogRepo notifyLogRepo, NotifyLogUUIDRepo notifyLogUUIDRepo, DBUtilRepo dbUtilRepo) {
        this.notifyLogRepo = notifyLogRepo;
        this.notifyLogUUIDRepo = notifyLogUUIDRepo;
        this.dbUtilRepo = dbUtilRepo;
    }

    @Transactional
    public Optional<NotifyLog> findById(Long id) {
        // example of using util repo to apply session settings within current transaction
        // https://www.postgresql.org/docs/15/runtime-config-query.html#RUNTIME-CONFIG-QUERY-ENABLE
        try {
            dbUtilRepo.disableNestedLoop();
            Optional<NotifyLog> byId = notifyLogRepo.finder(id);
            return byId;
        } catch (Exception ex) {
            throw ex;
        } finally {
            // not absolutely essential since the setting was "local" (only w/in the current tx)
            dbUtilRepo.enableNestedLoop();
        }
    }

    @Transactional
    public NotifyLog insertNotifyLog(NotifyLog notifyLog) {
        return notifyLogRepo.save(notifyLog);
    }

    public Optional<NotifyLogUUID> findById(UUID id) {
        Optional<NotifyLogUUID> byId = notifyLogUUIDRepo.findById(id);
        return byId;
    }

    @Transactional
    public NotifyLogUUID insertNotifyLogUUID(NotifyLogUUID notifyLogUUID) {
        return notifyLogUUIDRepo.save(notifyLogUUID);
    }
}
