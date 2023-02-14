package io.undertree.yb.domain.subscriptionlog;

import io.hypersistence.utils.hibernate.type.basic.PostgreSQLEnumType;
import io.undertree.yb.domain.device.Device;
import jakarta.persistence.*;
import org.hibernate.annotations.Type;

import java.util.Date;
import java.util.Objects;

@Entity
@Table(name = "yb_subscription_log")
//@org.hibernate.annotations.Entity(dynamicInsert = true)
public class SubscriptionLog {
    @Id
    private String externalSubscriptionId;

    private String partnerId;

    private String subscriptionId;

    private Date createdDate;

    private Date updatedDate;

    @Enumerated(EnumType.STRING)
    @Type(PostgreSQLEnumType.class)
    private RegistrationStatus registrationStatus;

    private Date startDate;

    private Date endDate;

    @Override
    public int hashCode() {
        return Objects.hashCode(externalSubscriptionId);
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
        return Objects.equals(externalSubscriptionId, other.getId());
    }

    ///

    public String getExternalSubscriptionId() {
        return externalSubscriptionId;
    }

    public void setExternalSubscriptionId(String externalSubscriptionId) {
        this.externalSubscriptionId = externalSubscriptionId;
    }

    public String getPartnerId() {
        return partnerId;
    }

    public void setPartnerId(String partnerId) {
        this.partnerId = partnerId;
    }

    public String getSubscriptionId() {
        return subscriptionId;
    }

    public void setSubscriptionId(String subscriptionId) {
        this.subscriptionId = subscriptionId;
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

    public RegistrationStatus getRegistrationStatus() {
        return registrationStatus;
    }

    public void setRegistrationStatus(RegistrationStatus registrationStatus) {
        this.registrationStatus = registrationStatus;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
}

// yugabyte=# \d yb_subscription_log
//                                  Table "public.yb_subscription_log"
//          Column          |           Type           | Collation | Nullable |         Default
//--------------------------+--------------------------+-----------+----------+--------------------------
// external_subscription_id | character varying(255)   |           | not null |
// partner_id               | character varying(255)   |           |          |
// subscription_id          | character varying(255)   |           |          |
// created_date             | timestamp with time zone |           | not null | CURRENT_TIMESTAMP
// updated_date             | timestamp with time zone |           | not null | CURRENT_TIMESTAMP
// registration_status      | option_state             |           | not null | 'INACTIVE'::option_state
// start_date               | timestamp with time zone |           |          |
// end_date                 | timestamp with time zone |           |          |
//Indexes:
//    "yb_subscription_log_pkey" PRIMARY KEY, lsm (external_subscription_id HASH)
//    "yb_subscription_log_partner_id_idx" lsm (partner_id HASH)