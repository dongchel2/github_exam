package com.example.catchMind.dto;

public class TimeMessage {
    private int timeLeft;

    public TimeMessage() {
    }

    public TimeMessage(int timeLeft) {
        this.timeLeft = timeLeft;
    }

    public int getTimeLeft() {
        return timeLeft;
    }

    public void setTimeLeft(int timeLeft) {
        this.timeLeft = timeLeft;
    }
}
