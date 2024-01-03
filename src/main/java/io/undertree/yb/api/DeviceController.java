package io.undertree.yb.api;

import io.undertree.yb.domain.device.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;

@RestController
@RequestMapping("/api/devices")
public class DeviceController {
    private final DeviceRepo deviceRepo;
    private final DeviceService deviceService;
    private final DeviceFollowerReadService deviceFollowerReadService;

    public DeviceController(DeviceRepo deviceRepo, DeviceService deviceService, DeviceFollowerReadService deviceFollowerReadService) {
        this.deviceRepo = deviceRepo;
        this.deviceService = deviceService;
        this.deviceFollowerReadService = deviceFollowerReadService;
    }

    @GetMapping("/models")
    public Collection<String> findDistinctModel() {
        return deviceRepo.findDistinctModels();
    }

    @GetMapping("/models/{model}")
    public Optional<Device> findByModel(@PathVariable String model) {
        return deviceRepo.findByModel(model);
    }

    @GetMapping("/")
    public Collection<DeviceVersion> findAllDeviceVersions() {
        return deviceFollowerReadService.getAll().orElse(Collections.emptyList());
    }
}
