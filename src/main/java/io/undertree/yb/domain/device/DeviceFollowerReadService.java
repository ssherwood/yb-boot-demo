package io.undertree.yb.domain.device;

import io.undertree.yb.domain.DBUtilRepo;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class DeviceFollowerReadService {

    private final DBUtilRepo dbUtilRepo;
    private final DeviceService deviceService;

    public DeviceFollowerReadService(DBUtilRepo dbUtilRepo, DeviceService deviceService) {
        this.dbUtilRepo = dbUtilRepo;
        this.deviceService = deviceService;
    }

    // don't start transaction here, enable follower reads first!!!
    public Optional<List<DeviceVersion>> getAll() {
        try {
            dbUtilRepo.enableFollowerRead();
            // this will start the transaction
            return deviceService.getAll();
        } finally {
            dbUtilRepo.disableFollowerRead();
        }
    }
}
