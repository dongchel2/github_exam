package com.example.catchMind.config;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import com.example.catchMind.controller.WebSocketController;
import com.example.catchMind.dto.CatchMindMessage;
import com.example.catchMind.service.UserSessionManager;

@Component
public class WebSocketEventListener {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    private final SimpMessagingTemplate messagingTemplate;
    private final UserSessionManager userSessionManager;
    private final WebSocketController webSocketController;

    public WebSocketEventListener(
        SimpMessagingTemplate messagingTemplate,
        UserSessionManager userSessionManager,
        WebSocketController webSocketController
    ) {
        this.messagingTemplate = messagingTemplate;
        this.userSessionManager = userSessionManager;
        this.webSocketController = webSocketController;
    }

    private void broadcastUserList() {
        List<String> nicknames = userSessionManager.getAllNicknames();
        messagingTemplate.convertAndSend("/topic/users", nicknames);
    }
    
    
    
    // 웹소켓 연결 시 닉네임 중복 검사
    @EventListener
    public void handleSessionConnected(SessionConnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = accessor.getSessionId();
        String nickname = accessor.getFirstNativeHeader("nickname");

        if (nickname == null || nickname.trim().isEmpty()) return;

        if (userSessionManager.isNicknameExists(nickname)) {
            throw new IllegalArgumentException("중복된 닉네임입니다: " + nickname);
        }

        userSessionManager.addUser(sessionId, nickname);
        logger.info("🟢 {}님이 접속했습니다.", nickname);

        // 닉네임 목록 브로드캐스트
        webSocketController.broadcastUserList();
    }

    // 웹소켓 연결 후 처리 (선택적)
    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        String nickname = headerAccessor.getFirstNativeHeader("nickname");

        if (nickname != null) {
            userSessionManager.addUser(sessionId, nickname); // 중복될 수 있음, 중복 검사는 위에서
        }
    }

    // 유저 퇴장 시
    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = accessor.getSessionId();

        String nickname = userSessionManager.removeUserBySessionId(sessionId);
        if (nickname != null) {
            logger.info("🔴 {}님이 퇴장했습니다.", nickname);

            CatchMindMessage leaveMsg = new CatchMindMessage();
            leaveMsg.setType("SYSTEM");
            leaveMsg.setSender("SYSTEM");
            leaveMsg.setContent(nickname + "님이 퇴장하셨습니다.");

            messagingTemplate.convertAndSend("/topic/game", leaveMsg);

            // 유저 리스트 브로드캐스트
            webSocketController.broadcastUserList();
            
            

   
            
            
            
            
        }
    }
}
