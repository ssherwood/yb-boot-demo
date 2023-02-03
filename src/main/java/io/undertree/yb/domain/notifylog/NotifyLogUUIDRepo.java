package io.undertree.yb.domain.notifylog;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NotifyLogUUIDRepo extends JpaRepository<NotifyLogUUID, UUID> {
}
