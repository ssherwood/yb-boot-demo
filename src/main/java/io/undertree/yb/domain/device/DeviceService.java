package io.undertree.yb.domain.device;

import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class DeviceService {
    private final DeviceRepo deviceRepo;

    public DeviceService(DeviceRepo deviceRepo) {
        this.deviceRepo = deviceRepo;
    }

    public void process(String model) {
        Optional<Device> byModel = deviceRepo.findByModel(model);

        if (byModel.isPresent()) {

        }
    }
}
