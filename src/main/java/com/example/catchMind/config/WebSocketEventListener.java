package com.example.catchMind.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import com.example.catchMind.dto.CatchMindMessage;
import com.example.catchMind.service.GameBroadcasterService;
import com.example.catchMind.service.UserSessionManager;

@Component
public class WebSocketEventListener {

    private static final Logger log = LoggerFactory.getLogger(WebSocketEventListener.class);

    private final UserSessionManager userSessionManager;
    private final GameBroadcasterService broadcaster;

    public WebSocketEventListener(UserSessionManager userSessionManager,
                                  GameBroadcasterService broadcaster) {
        this.userSessionManager = userSessionManager;
        this.broadcaster = broadcaster;
    }

    @EventListener
    public void handleSessionConnected(SessionConnectEvent event) {
        // 연결 시 처리할 내용이 있다면 여기에 구현
        log.info("🟢 WebSocket 연결됨");
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = accessor.getSessionId();

        String nickname = userSessionManager.removeUserBySessionId(sessionId);
        if (nickname != null) {
            log.info("🔴 {}님이 퇴장하셨습니다", nickname);

            CatchMindMessage leaveMsg = new CatchMindMessage(
                    CatchMindMessage.MessageType.SYSTEM,
                    "SYSTEM",
                    nickname + "님이 퇴장하셨습니다."
            );
            broadcaster.broadcastSystemMessage(leaveMsg.getContent());
            broadcaster.broadcastUserList(userSessionManager.getAllNicknames());
        }
    }
}
