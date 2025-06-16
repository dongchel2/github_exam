package com.example.catchMind.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.catchMind.dao.GameTimer;
import com.example.catchMind.dto.CatchMindMessage;
import com.example.catchMind.service.UserSessionManager;

@Controller
public class WebSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final GameTimer gameTimer;
    private final UserSessionManager userSessionManager;

    private final List<String> playerList = new ArrayList<>();
    private final ConcurrentHashMap<String, Boolean> playerStatus = new ConcurrentHashMap<>();
    private int currentDrawerIndex = 0;
    private String answer = "";
    private boolean answered = false;

 // 생성자 수정
    public WebSocketController(SimpMessagingTemplate messagingTemplate, GameTimer gameTimer, UserSessionManager userSessionManager) {
        this.messagingTemplate = messagingTemplate;
        this.gameTimer = gameTimer;
        this.userSessionManager = userSessionManager;
    }

    @MessageMapping("/game/enter")
    public void onPlayerEnter(@Payload CatchMindMessage message) {
        String nickname = message.getSender();
        if (!playerList.contains(nickname)) {
            playerList.add(nickname);
            playerStatus.put(nickname, false);
        }

        broadcastUserList();
        notifyCurrentDrawer();
    }

    @MessageMapping("/game/send")
    public void handleMessage(@Payload CatchMindMessage message) {
        if ("DRAW".equals(message.getType())) {
            messagingTemplate.convertAndSend("/topic/draw", message);
        } else if ("CHAT".equals(message.getType())) {
            String msg = message.getContent().trim().toLowerCase();

            if (answer != null && !answered && answer.equals(msg)) {
                answered = true;

                CatchMindMessage correctMsg = new CatchMindMessage();
                correctMsg.setType("SYSTEM");
                correctMsg.setSender("SYSTEM");
                correctMsg.setContent(message.getSender() + "님이 정답을 맞췄습니다! 🎉");

                messagingTemplate.convertAndSend("/topic/game", correctMsg);
                gameTimer.stopTimer(); // 정답 시 타이머 중지

                // 바로 다음 턴으로 넘기기
                nextTurn();
            } else {
                messagingTemplate.convertAndSend("/topic/game", message);
            }
        }
    }

    @MessageMapping("/game/setAnswer")
    public void setAnswer(@Payload CatchMindMessage message) {
        this.answer = message.getContent().trim().toLowerCase();
        this.answered = false;

        gameTimer.start(this::nextTurn); // 타이머 시작
    }

    @MessageMapping("/game/nextTurn")
    public void nextTurn() {
        if (playerList.isEmpty()) return;

        currentDrawerIndex = (currentDrawerIndex + 1) % playerList.size();
        String nextDrawer = playerList.get(currentDrawerIndex);

        CatchMindMessage turnMsg = new CatchMindMessage();
        turnMsg.setType("SYSTEM");
        turnMsg.setSender("SYSTEM");
        turnMsg.setContent("출제자가 " + nextDrawer + "님으로 변경되었습니다!");

        messagingTemplate.convertAndSend("/topic/game", turnMsg);
        notifyCurrentDrawer(); // 현재 출제자 정보 전송

        gameTimer.start(this::nextTurn); // 다음 라운드 타이머 시작
    }

    public void notifyCurrentDrawer() {
        if (!playerList.isEmpty()) {
            String currentDrawer = playerList.get(currentDrawerIndex);

            CatchMindMessage drawerMsg = new CatchMindMessage();
            drawerMsg.setType("DRAWER");
            drawerMsg.setSender("SYSTEM");
            drawerMsg.setContent(currentDrawer);

            messagingTemplate.convertAndSend("/topic/drawer", drawerMsg);
        }
    }

    public void broadcastUserList() {
    	List<String> nicknames = userSessionManager.getAllNicknames();
    	
    	
        CatchMindMessage userListMsg = new CatchMindMessage();
        userListMsg.setType("USER_LIST");
        userListMsg.setSender("SYSTEM");
        userListMsg.setContent(String.join(",", playerList));

        messagingTemplate.convertAndSend("/topic/userlist", userListMsg);
    }
}
