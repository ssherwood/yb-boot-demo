package io.undertree.yb.domain.tracker;

import org.springframework.jdbc.core.DataClassRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSourceUtils;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

@Repository
public class TrackerRepo {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    public TrackerRepo(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public DeviceTrackerData saveNew(DeviceTrackerData deviceTrackerData) {
        var params = Map.of(
                "deviceId", deviceTrackerData.deviceId(),
                "mediaId", deviceTrackerData.mediaId(),
                "status", deviceTrackerData.status(),
                "createdDate", deviceTrackerData.createdDate(),
                "updatedDate", deviceTrackerData.updatedDate());

        var rows = jdbcTemplate.update("INSERT INTO yb_device_tracker(device_id, media_id, status, created_date, updated_date) VALUES(:deviceId, :mediaId, :status, :createdDate, :updatedDate);", params);
        return jdbcTemplate.queryForObject("SELECT * FROM yb_device_tracker where device_id = :deviceId", Map.of("deviceId", deviceTrackerData.deviceId()), new DataClassRowMapper<>(DeviceTrackerData.class));
    }

    public DeviceTrackerData updateStatusEvent(DeviceTrackerUpdate deviceTrackerData) {
        var params = Map.of(
                "deviceId", deviceTrackerData.deviceId(),
                "mediaId", deviceTrackerData.mediaId(),
                "newStatus", deviceTrackerData.status(),
                "now", OffsetDateTime.now());

        var rows = jdbcTemplate.update("UPDATE yb_device_tracker SET status = :newStatus, updated_date = :now WHERE device_id = :deviceId AND media_id = :mediaId", params);
        return jdbcTemplate.queryForObject("SELECT * FROM yb_device_tracker where device_id = :deviceId and media_id = :mediaId",
                Map.of("deviceId", deviceTrackerData.deviceId(), "mediaId", deviceTrackerData.mediaId()), new DataClassRowMapper<>(DeviceTrackerData.class));
    }

    @Transactional //causes tx conflict errors, bigger batches == more conflicts
    public int[] batchUpdateStatusEvent(List<DeviceTrackerBatchUpdate> deviceTrackerData) {
        SqlParameterSource[] batch = SqlParameterSourceUtils.createBatch(deviceTrackerData);
        return jdbcTemplate.batchUpdate("UPDATE yb_device_tracker SET status = :status, updated_date = current_timestamp WHERE device_id = :deviceId AND media_id = :mediaId", batch);
    }
}
