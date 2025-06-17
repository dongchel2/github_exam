package com.example.catchMind.domain;

public class User {
    private final String sessionId;
    private final String nickname;
    private int score;
    private boolean isDrawer;

    public User(String sessionId, String nickname) {
        this.sessionId = sessionId;
        this.nickname = nickname;
        this.score = 0;
        this.isDrawer = false;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getNickname() {
        return nickname;
    }

    public int getScore() {
        return score;
    }

    public void addScore(int amount) {
        this.score += amount;
    }

    public boolean isDrawer() {
        return isDrawer;
    }

    public void setDrawer(boolean isDrawer) {
        this.isDrawer = isDrawer;
    }
}
