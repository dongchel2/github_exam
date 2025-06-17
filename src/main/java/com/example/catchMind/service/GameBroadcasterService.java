package com.example.catchMind.service;

import com.example.catchMind.domain.User;
import com.example.catchMind.dto.CatchMindMessage;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class GameBroadcasterService {

    private final SimpMessagingTemplate messagingTemplate;

    public GameBroadcasterService(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    public void broadcastChatMessage(String sender, String content) {
        CatchMindMessage msg = new CatchMindMessage("CHAT", sender, content);
        messagingTemplate.convertAndSend("/topic/game", msg);
    }

    public void broadcastSystemMessage(String content) {
        CatchMindMessage msg = new CatchMindMessage("SYSTEM", "SYSTEM", content);
        messagingTemplate.convertAndSend("/topic/game", msg);
    }

    public void broadcastDrawData(CatchMindMessage drawMsg) {
        messagingTemplate.convertAndSend("/topic/draw", drawMsg);
    }

    public void notifyCurrentDrawer(String nickname) {
        CatchMindMessage drawerMsg = new CatchMindMessage("DRAWER", "SYSTEM", nickname);
        messagingTemplate.convertAndSend("/topic/drawer", drawerMsg);
    }

    public void broadcastUserList(List<String> nicknames) {
        CatchMindMessage userListMsg = new CatchMindMessage("USER_LIST", "SYSTEM", String.join(",", nicknames));
        messagingTemplate.convertAndSend("/topic/userlist", userListMsg);
    }

    public void broadcastScoreBoard(Map<String, User> userMap) {
        StringBuilder sb = new StringBuilder("🏆 점수판\n");
        userMap.values().stream()
                .sorted((u1, u2) -> Integer.compare(u2.getScore(), u1.getScore()))
                .forEach(u -> sb.append(u.getNickname()).append(" : ").append(u.getScore()).append("점\n"));

        broadcastSystemMessage(sb.toString());
    }
}
