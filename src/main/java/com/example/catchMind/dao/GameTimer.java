package com.example.catchMind.dao;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.example.catchMind.dto.TimeMessage;

@Component
public class GameTimer {

    private final SimpMessagingTemplate messagingTemplate;

    private ScheduledExecutorService scheduler;
    private int timeLeft;

    public GameTimer(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    // 타이머 시작 - 콜백만 받는 버전 (WebSocketController에서 사용)
    public void start(Runnable onTimeout) {
        stopTimer(); // 기존 타이머 중지

        timeLeft = 60; // 60초
        scheduler = Executors.newSingleThreadScheduledExecutor();

        scheduler.scheduleAtFixedRate(() -> {
            // 시간 메시지 전송
            messagingTemplate.convertAndSend("/topic/timer", new TimeMessage(timeLeft));

            if (timeLeft <= 0) {
                stopTimer(); // 타이머 중지
                onTimeout.run(); // 콜백 실행 (ex: nextTurn())
            }

            timeLeft--;
        }, 0, 1, TimeUnit.SECONDS);
    }

    // 타이머 중지 메서드
    public void stopTimer() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }
}
