package io.undertree.yb.domain.device;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceVersionRepo extends JpaRepository<DeviceVersion, Long> {
    @Query("FROM DeviceVersion where deprecated = false and id in (SELECT id FROM Device)")
    Optional<List<DeviceVersion>> findAllDeviceVersions();
}
