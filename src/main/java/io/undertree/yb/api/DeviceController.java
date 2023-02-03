package io.undertree.yb.api;

import io.undertree.yb.domain.device.Device;
import io.undertree.yb.domain.device.DeviceRepo;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;
import java.util.Optional;

@RestController
@RequestMapping("/api/devices")
public class DeviceController {
    private final DeviceRepo deviceRepo;

    public DeviceController(DeviceRepo deviceRepo) {
        this.deviceRepo = deviceRepo;
    }

    @GetMapping("/models")
    public Collection<String> findDistinctModel() {
        return deviceRepo.findDistinctModels();
    }

    @GetMapping("/models/{model}")
    public Optional<Device> findByModel(@PathVariable String model) {
        return deviceRepo.findByModel(model);
    }
}
