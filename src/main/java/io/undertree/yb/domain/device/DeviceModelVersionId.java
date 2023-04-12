package io.undertree.yb.domain.device;

import jakarta.persistence.Id;

import java.io.Serializable;
import java.util.Objects;

public class DeviceModelVersionId implements Serializable {
    private Long versionId;
    private String model;

    public DeviceModelVersionId() {
    }

    public DeviceModelVersionId(Long versionId, String model) {
        this.versionId = versionId;
        this.model = model;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        DeviceModelVersionId that = (DeviceModelVersionId) o;

        if (!Objects.equals(versionId, that.versionId)) return false;
        return Objects.equals(model, that.model);
    }

    @Override
    public int hashCode() {
        int result = versionId != null ? versionId.hashCode() : 0;
        result = 31 * result + (model != null ? model.hashCode() : 0);
        return result;
    }

    public Long getVersionId() {
        return versionId;
    }

    public void setVersionId(Long versionId) {
        this.versionId = versionId;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }
}
