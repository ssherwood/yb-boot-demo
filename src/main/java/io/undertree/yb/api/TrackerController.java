package io.undertree.yb.api;

import io.undertree.yb.domain.tracker.DeviceTrackerBatchUpdate;
import io.undertree.yb.domain.tracker.DeviceTrackerData;
import io.undertree.yb.domain.tracker.DeviceTrackerUpdate;
import io.undertree.yb.domain.tracker.TrackerRepo;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/tracker")
public class TrackerController {
    private final TrackerRepo trackerRepo;
    private final Random random = new Random();

    public TrackerController(TrackerRepo trackerRepo) {
        this.trackerRepo = trackerRepo;
    }

    // Faux method to generate new data
    @PostMapping("/{id}")
    public DeviceTrackerData addNew(@PathVariable Long id) {
        return trackerRepo.saveNew(DeviceTrackerData.newFake(id));
    }

    @PatchMapping()
    public DeviceTrackerData update(@RequestBody DeviceTrackerUpdate deviceTrackerUpdate) {
        return trackerRepo.updateStatusEvent(deviceTrackerUpdate);
    }

    @PostMapping("/batch/{batchSize}")
    public int[] batchUpdate(@PathVariable int batchSize) {
        List<DeviceTrackerBatchUpdate> batchUpdate = new ArrayList<>();
        for (int i = 0; i < batchSize; i++) {
            batchUpdate.add(generateDeviceUpdate());
        }
        //batchUpdate.add(generateBrokenDeviceUpdate());

        return trackerRepo.batchUpdateStatusEvent(batchUpdate);
    }

    private DeviceTrackerBatchUpdate generateDeviceUpdate() {
        var devId = random.nextInt(11000);
        return new DeviceTrackerBatchUpdate(randomDevice(devId), randomContent(devId), randomStatus(), OffsetDateTime.now());
    }

    private DeviceTrackerBatchUpdate generateBrokenDeviceUpdate() {
        var devId = random.nextInt(11000);
        return new DeviceTrackerBatchUpdate(randomDevice(devId), randomContent(devId), "FOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO", OffsetDateTime.now());
    }

    private String randomStatus() {
        return String.format("M05-%d", random.nextInt(99));
    }

    private String randomContent(int devId) {
        return String.format("48d1c2c2-0d83-43d9-%04d-%012d", random.nextInt(60), devId);
    }

    private UUID randomDevice(int devId) {
        return UUID.fromString(String.format("cdd7cacd-8e0a-4372-8ceb-%012d", devId));
    }
}
