package io.undertree.yb.domain.device;

import io.undertree.yb.domain.DBUtilRepo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class DeviceService {
    final static Logger LOGGER = LoggerFactory.getLogger(DeviceService.class);

    private final DeviceRepo deviceRepo;
    private final DeviceModelRepo deviceModelRepo;
    private final DeviceVersionRepo deviceVersionRepo;
    private final DeviceModelVersionRepo deviceModelVersionRepo;
    private final DBUtilRepo dbUtilRepo;

    public DeviceService(DeviceRepo deviceRepo, DeviceModelRepo deviceModelRepo, DeviceVersionRepo deviceVersionRepo, DeviceModelVersionRepo deviceModelVersionRepo, DBUtilRepo dbUtilRepo) {
        this.deviceRepo = deviceRepo;
        this.deviceModelRepo = deviceModelRepo;
        this.deviceVersionRepo = deviceVersionRepo;
        this.deviceModelVersionRepo = deviceModelVersionRepo;
        this.dbUtilRepo = dbUtilRepo;
    }

    public void process(String model) {
        Optional<Device> byModel = deviceRepo.findByModel(model);
    }

    private void logIt(String message, long startTime, long endTime) {
        if ((endTime - startTime) > 1000) {
            LOGGER.info(message + ": " + (endTime - startTime) + "ms");
        }
    }

    //@Cacheable("deviceVersions")
    @Transactional(readOnly = true)
    public Optional<List<DeviceVersion>> getAll() {
        try {
            dbUtilRepo.setSessionReadOnly();
            dbUtilRepo.disableNestedLoop();
            dbUtilRepo.disableSeqScan();

            var startTime = System.currentTimeMillis();
            var devices = deviceRepo.findAllByOrderByModelAsc();
            var endTime = System.currentTimeMillis();
            logIt("1. Device Query", startTime, endTime);

            startTime = System.currentTimeMillis();
            var deviceModels = deviceModelRepo.findAllDeviceModels();
            endTime = System.currentTimeMillis();
            logIt("2. Device Model Query", startTime, endTime);

            startTime = System.currentTimeMillis();
            var deviceVersions = deviceVersionRepo.findAllDeviceVersions();
            endTime = System.currentTimeMillis();
            logIt("3. Device Version Query", startTime, endTime);

            startTime = System.currentTimeMillis();
            var deviceModelVersions = deviceModelVersionRepo.findAllDeviceModelVersions();
            endTime = System.currentTimeMillis();
            logIt("4. Device Model Version Query", startTime, endTime);

            return deviceVersions;
        } catch (Exception ex) {
            LOGGER.error("Unexpected exception :: " + ex, ex);
            throw ex;
        } finally {
            dbUtilRepo.enableSeqScan();
            dbUtilRepo.enableNestedLoop();
        }
    }

    //@CacheEvict(cacheNames = "deviceVersions", allEntries = true)
    //@Scheduled(fixedDelayString = "${app.caching.deviceVersionExpiryMs}", initialDelay = 30000)
    public void evictDeviceVersionCache() {
        LOGGER.info("Evicting 'deviceVersions' cache...");
    }
}
