package com.example.catchMind.controller;

import com.example.catchMind.dto.CatchMindMessage;
import com.example.catchMind.service.GameBroadcasterService;
import com.example.catchMind.service.GameService;
import com.example.catchMind.service.UserSessionManager;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    private final UserSessionManager userSessionManager;
    private final GameService gameService;
    private final GameBroadcasterService broadcaster;

    public WebSocketController(UserSessionManager userSessionManager,
                               GameService gameService,
                               GameBroadcasterService broadcaster) {
        this.userSessionManager = userSessionManager;
        this.gameService = gameService;
        this.broadcaster = broadcaster;
    }

    // 유저 입장 처리
    @MessageMapping("/game/enter")
    public void handleEnter(@Payload CatchMindMessage message, SimpMessageHeaderAccessor accessor) {
        String sessionId = accessor.getSessionId();
        String nickname = message.getSender();



        userSessionManager.addUser(sessionId, nickname);
        broadcaster.broadcastSystemMessage(nickname + "님이 입장하셨습니다!");
        broadcaster.broadcastUserList(userSessionManager.getAllNicknames());
        broadcaster.notifyCurrentDrawer(gameService.getCurrentDrawer());
    }

    // 일반 메시지 or 드로잉 or 정답 처리
    @MessageMapping("/game/send")
    public void handleMessage(@Payload CatchMindMessage message) {
        switch (message.getType()) {
            case CHAT -> gameService.handleChat(message.getSender(), message.getContent());
            case DRAW -> broadcaster.broadcastDrawData(message);
            default -> broadcaster.broadcastSystemMessage("알 수 없는 메시지 유형입니다.");
        }
    }

    // 출제자가 정답을 설정했을 때
    @MessageMapping("/game/setAnswer")
    public void setAnswer(@Payload CatchMindMessage message) {
        gameService.setAnswer(message.getContent());
    }

    // 수동 턴 넘기기 (선택사항)
    @MessageMapping("/game/nextTurn")
    public void nextTurn() {
        gameService.nextTurn();
    }
}
