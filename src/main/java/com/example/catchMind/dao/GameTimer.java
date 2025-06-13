package com.example.catchMind.dao;

import com.example.catchMind.dto.CatchMindMessage;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.util.concurrent.*;

public class GameTimer {
    private final ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
    private ScheduledFuture<?> futureTask;

    private final SimpMessagingTemplate messagingTemplate;
    private final Runnable onTimeout;
    private final int seconds;

    public GameTimer(SimpMessagingTemplate messagingTemplate, Runnable onTimeout, int seconds) {
        this.messagingTemplate = messagingTemplate;
        this.onTimeout = onTimeout;
        this.seconds = seconds;
    }

    public void start() {
        stop(); // 이전 타이머 종료
        futureTask = scheduler.schedule(onTimeout, seconds, TimeUnit.SECONDS);

        CatchMindMessage startMsg = new CatchMindMessage();
        startMsg.setType("SYSTEM");
        startMsg.setSender("시스템");
        startMsg.setContent("⏱ 제한 시간 " + seconds + "초 시작!");
        messagingTemplate.convertAndSend("/topic/game", startMsg);
    }

    public void stop() {
        if (futureTask != null && !futureTask.isDone()) {
            futureTask.cancel(true);
        }
    }
}
