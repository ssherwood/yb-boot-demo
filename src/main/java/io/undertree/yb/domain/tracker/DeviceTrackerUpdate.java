package io.undertree.yb.domain.tracker;

import java.util.UUID;

public record DeviceTrackerUpdate(UUID deviceId, String mediaId, String status) {
}
