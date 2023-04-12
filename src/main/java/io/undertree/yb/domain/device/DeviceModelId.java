package io.undertree.yb.domain.device;

import java.io.Serializable;
import java.util.Objects;

public class DeviceModelId implements Serializable {
    private Long deviceId;
    private String model;

    public DeviceModelId() {
    }

    public DeviceModelId(Long deviceId, String model) {
        this.deviceId = deviceId;
        this.model = model;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        DeviceModelId that = (DeviceModelId) o;

        if (!Objects.equals(deviceId, that.deviceId)) return false;
        return Objects.equals(model, that.model);
    }

    @Override
    public int hashCode() {
        int result = deviceId != null ? deviceId.hashCode() : 0;
        result = 31 * result + (model != null ? model.hashCode() : 0);
        return result;
    }
}
