package com.example.catchMind.domain;

import java.util.concurrent.atomic.AtomicBoolean;

import org.springframework.stereotype.Component;


@Component
public class GameState {
    private String currentAnswer = "";
    private String currentDrawer = "";
    private final AtomicBoolean answered = new AtomicBoolean(false);

    public String getCurrentAnswer() {
        return currentAnswer;
    }

    public void setCurrentAnswer(String currentAnswer) {
        this.currentAnswer = currentAnswer;
        this.answered.set(false); // 새 정답 설정 시 초기화
    }

    public boolean isAnswered() {
        return answered.get();
    }

    public void setAnswered(boolean value) {
        answered.set(value);
    }

    public String getCurrentDrawer() {
        return currentDrawer;
    }

    public void setCurrentDrawer(String currentDrawer) {
        this.currentDrawer = currentDrawer;
    }

    public void reset() {
        currentAnswer = "";
        currentDrawer = "";
        answered.set(false);
    }
}
