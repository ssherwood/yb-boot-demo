package io.undertree.yb.domain;

import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.util.Optional;
import java.util.UUID;

@Service
public class NotifyLogService {
    private final YBNotifyLogRepo notifyLogRepo;
    private final NotifyLogUUIDRepo notifyLogUUIDRepo;

    public NotifyLogService(YBNotifyLogRepo notifyLogRepo, NotifyLogUUIDRepo notifyLogUUIDRepo) {
        this.notifyLogRepo = notifyLogRepo;
        this.notifyLogUUIDRepo = notifyLogUUIDRepo;
    }

    //@Transactional
    public Optional<NotifyLog> findById(Long id) {
        //notifyLogRepo.turnOff();
        Optional<NotifyLog> byId = notifyLogRepo.finder(id);
        //notifyLogRepo.turnOn();
        return byId;
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
