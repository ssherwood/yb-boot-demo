package io.undertree.yb.domain.device;

import jakarta.persistence.*;

import java.util.Date;
import java.util.Objects;

@Entity
@Table(name = "yb_device")
public class Device {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "yb_device_id_gen")
    @SequenceGenerator(name = "yb_device_id_gen", sequenceName = "yb_device_id_seq", allocationSize = 1)
    @Column(name = "id", nullable = false)
    private Long id;

    private Date createdDate;

    private Date updatedDate;

    private String model;

    private Long partnerId;

    private String partnerToken;

    private String secret;

    private String version;

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
        Device other = (Device) obj;
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

    public Date getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(Date updatedDate) {
        this.updatedDate = updatedDate;
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

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
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

/*
                                        Table "public.yb_device"
    Column     |           Type           | Collation | Nullable |                Default
---------------+--------------------------+-----------+----------+---------------------------------------
 id            | bigint                   |           | not null | nextval('yb_device_id_seq'::regclass)
 created_date  | timestamp with time zone |           | not null | CURRENT_TIMESTAMP
 updated_date  | timestamp with time zone |           | not null | CURRENT_TIMESTAMP
 model         | text                     |           |          |
 partner_id    | bigint                   |           | not null |
 partner_token | text                     |           | not null |
 secret        | text                     |           | not null |
 version       | character varying(30)    |           | not null |
 build_number  | integer                  |           |          |
 version_notes | text                     |           |          |
 deprecated    | boolean                  |           |          |

 */