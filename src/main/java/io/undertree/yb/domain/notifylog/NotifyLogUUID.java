package io.undertree.yb.domain.notifylog;

import javax.persistence.*;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "yb_notify_log_uuid")
public class NotifyLogUUID {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(name = "ingest_date")
    private Date ingestDate;

    @Column(name = "notification")
    private String notification;

    @Column(name = "subscription_id")
    private String subscriptionId;

    @Column(name = "user_id")
    private Long userId;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Date getIngestDate() {
        return ingestDate;
    }

    public void setIngestDate(Date ingestDate) {
        this.ingestDate = ingestDate;
    }

    public String getNotification() {
        return notification;
    }

    public void setNotification(String notification) {
        this.notification = notification;
    }

    public String getSubscriptionId() {
        return subscriptionId;
    }

    public void setSubscriptionId(String subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
