package io.undertree.yb.domain.notifylog;

import jakarta.persistence.*;

import java.util.Date;

//@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "yb_notify_log_id_gen")
//@SequenceGenerator(name = "yb_notify_log_id_gen", sequenceName = "yb_notify_log_id_seq", allocationSize = 1)

@Entity
@Table(name = "yb_notify_log")
public class NotifyLog {

    @Id
//    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "yb_notify_log_id_gen")
//    @GenericGenerator(name = "yb_notify_log_id_gen", strategy = "io.undertree.yb.hibernate.YugabyteSequenceGenerator", parameters = {
//            @org.hibernate.annotations.Parameter(name = "sequence_name", value = "yb_notify_log_id_%02d_seq"),
//            @org.hibernate.annotations.Parameter(name = "sequence_max_buckets", value = "3"),
//            @org.hibernate.annotations.Parameter(name = SequenceStyleGenerator.INCREMENT_PARAM, value = "100")
//    })
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "yb_notify_log_id_gen")
    @SequenceGenerator(name = "yb_notify_log_id_gen", sequenceName = "yb_notify_log_id_seq", allocationSize = 1)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "ingest_date")
    private Date ingestDate;

    @Column(name = "notification")
    private String notification;

    @Column(name = "subscription_id")
    private String subscriptionId;

    @Column(name = "user_id")
    private Long userId;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
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
