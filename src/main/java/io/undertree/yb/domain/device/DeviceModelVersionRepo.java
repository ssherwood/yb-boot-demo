package io.undertree.yb.domain.device;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface DeviceModelVersionRepo extends JpaRepository<DeviceModelVersion, Long> {
    @Query("FROM DeviceModelVersion where versionId in (SELECT id FROM DeviceVersion where deprecated = false and id in (SELECT id from Device ))")
    Optional<List<DeviceModelVersion>> findAllDeviceModelVersions();
}
