package io.undertree.yb.domain.device;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@IdClass(DeviceModelVersionId.class)
@Table(name = "yb_device_model_version")
public class DeviceModelVersion {

    @Id
    private Long versionId;

    @Id
    private String model;

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
