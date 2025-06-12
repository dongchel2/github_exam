package com.example.catchMind.dto;

public class CatchMindMessage {

    private String type;
    private String sender;
    private String content;

    private int x1;
    private int y1;
    private int x2;
    private int y2;
    private String color;

    public CatchMindMessage() {}

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getX1() { return x1; }
    public void setX1(int x1) { this.x1 = x1; }

    public int getY1() { return y1; }
    public void setY1(int y1) { this.y1 = y1; }

    public int getX2() { return x2; }
    public void setX2(int x2) { this.x2 = x2; }

    public int getY2() { return y2; }
    public void setY2(int y2) { this.y2 = y2; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
}
