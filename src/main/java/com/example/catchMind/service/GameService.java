package com.example.catchMind.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.catchMind.domain.GameState;

@Service
public class GameService {

    private final UserSessionManager userSessionManager;
    private final GameState gameState;
    private final GameBroadcasterService broadcaster;
    private int currentDrawerIndex = 0;

    public GameService(UserSessionManager userSessionManager,
                       GameState gameState,
                       GameBroadcasterService broadcaster) {
        this.userSessionManager = userSessionManager;
        this.gameState = gameState;
        this.broadcaster = broadcaster;
    }

    public void setAnswer(String answer) {
        gameState.setCurrentAnswer(answer.trim().toLowerCase());
        gameState.setAnswered(false);

        broadcaster.broadcastSystemMessage("정답이 설정되었습니다! 게임이 시작됩니다.");
        broadcaster.notifyCurrentDrawer(getCurrentDrawer());
    }

    public void handleChat(String sender, String message) {
        String trimmed = message.trim().toLowerCase();

        if (!gameState.isAnswered() && trimmed.equals(gameState.getCurrentAnswer())) {
            gameState.setAnswered(true);
            userSessionManager.addScore(sender, 10);

            broadcaster.broadcastSystemMessage(sender + "님이 정답을 맞췄습니다! 🎉");
            broadcaster.broadcastScoreBoard(userSessionManager.getAllUsers());

            nextTurn();
        } else {
            broadcaster.broadcastChatMessage(sender, message);
        }
    }

    public void nextTurn() {
        List<String> nicknames = userSessionManager.getAllNicknames();
        if (nicknames.isEmpty()) return;

        currentDrawerIndex = (currentDrawerIndex + 1) % nicknames.size();
        String nextDrawer = nicknames.get(currentDrawerIndex);

        gameState.setCurrentDrawer(nextDrawer);
        gameState.setCurrentAnswer("");
        gameState.setAnswered(false);
        userSessionManager.setDrawer(nextDrawer);

        broadcaster.broadcastSystemMessage("출제자가 " + nextDrawer + "님으로 변경되었습니다.");
        broadcaster.notifyCurrentDrawer(nextDrawer);
    }

    public String getCurrentDrawer() {
        return gameState.getCurrentDrawer();
    }
}
