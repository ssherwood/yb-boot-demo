package io.undertree.yb.api;

import io.undertree.yb.domain.subscriptionlog.SubscriptionLog;
import io.undertree.yb.domain.subscriptionlog.SubscriptionLogService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/subscriptions")
public class SubscriptionLogController {

    private final SubscriptionLogService subscriptionLogService;

    public SubscriptionLogController(SubscriptionLogService subscriptionLogService) {
        this.subscriptionLogService = subscriptionLogService;
    }


    @PostMapping
    public ResponseEntity<SubscriptionLog> addOrUpdateSubscriptionLog(@RequestBody SubscriptionLog subscriptionLog) {
        return ResponseEntity.ok(subscriptionLogService.saveOrUpdateSubscriptionLog(subscriptionLog));
    }
}
