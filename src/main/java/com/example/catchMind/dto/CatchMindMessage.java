package com.example.catchMind.dto;

public class CatchMindMessage {

    private MessageType type;
    private String sender;
    private String content;

    // (선택적) 그림 좌표 관련 필드
    private int x1;
    private int y1;
    private int x2;
    private int y2;
    private String color;

    public CatchMindMessage() {
    }

    public CatchMindMessage(String type, String sender, String content) {
        this.type = MessageType.valueOf(type.toUpperCase());
        this.sender = sender;
        this.content = content;
    }

    public CatchMindMessage(MessageType type, String sender, String content) {
        this.type = type;
        this.sender = sender;
        this.content = content;
    }

    public MessageType getType() {
        return type;
    }

    public void setType(MessageType type) {
        this.type = type;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getX1() {
        return x1;
    }

    public void setX1(int x1) {
        this.x1 = x1;
    }

    public int getY1() {
        return y1;
    }

    public void setY1(int y1) {
        this.y1 = y1;
    }

    public int getX2() {
        return x2;
    }

    public void setX2(int x2) {
        this.x2 = x2;
    }

    public int getY2() {
        return y2;
    }

    public void setY2(int y2) {
        this.y2 = y2;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public enum MessageType {
        DRAW, CHAT, SYSTEM, ANSWER, DRAWER, USER_LIST
    }
}
