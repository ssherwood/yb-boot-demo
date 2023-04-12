package io.undertree.yb.domain.device;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceModelRepo extends JpaRepository<DeviceModel, Long> {
    @Query("FROM DeviceModel where deviceId in (SELECT id FROM Device)")
    Optional<List<DeviceModel>> findAllDeviceModels();
}
