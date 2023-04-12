package io.undertree.yb.domain.device;

import jakarta.persistence.*;

import java.util.Date;
import java.util.Objects;

@Entity
@Table(name = "yb_device_version")
public class DeviceVersion {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "yb_device_version_id_gen")
    @SequenceGenerator(name = "yb_device_version_id_gen", sequenceName = "yb_device_version_id_seq", allocationSize = 1)
    @Column(name = "id", nullable = false)
    private Long id;

    private Date createdDate;

    private String createdBy;

    private Date updatedDate;

    private String updatedBy;

    private String model;

    private Long partnerId;

    private String partnerToken;

    private String secret;

    private Integer version;

    private Integer buildNumber;

    private String versionNotes;

    private Boolean deprecated;

    @Override
    public int hashCode() {
        return Objects.hashCode(id);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        DeviceVersion other = (DeviceVersion) obj;
        return Objects.equals(id, other.getId());
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public Date getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(Date updatedDate) {
        this.updatedDate = updatedDate;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public Long getPartnerId() {
        return partnerId;
    }

    public void setPartnerId(Long partnerId) {
        this.partnerId = partnerId;
    }

    public String getPartnerToken() {
        return partnerToken;
    }

    public void setPartnerToken(String partnerToken) {
        this.partnerToken = partnerToken;
    }

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }

    public Integer getBuildNumber() {
        return buildNumber;
    }

    public void setBuildNumber(Integer buildNumber) {
        this.buildNumber = buildNumber;
    }

    public String getVersionNotes() {
        return versionNotes;
    }

    public void setVersionNotes(String versionNotes) {
        this.versionNotes = versionNotes;
    }

    public Boolean getDeprecated() {
        return deprecated;
    }

    public void setDeprecated(Boolean deprecated) {
        this.deprecated = deprecated;
    }
}