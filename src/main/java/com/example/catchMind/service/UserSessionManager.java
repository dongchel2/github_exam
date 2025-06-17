package com.example.catchMind.service;

import com.example.catchMind.domain.User;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserSessionManager {

    // 세션 ID -> User 객체 매핑
    private final Map<String, User> sessionUserMap = new ConcurrentHashMap<>();

    // 유저 추가
    public void addUser(String sessionId, String nickname) {
        sessionUserMap.put(sessionId, new User(sessionId, nickname));
    }

    // 유저 제거 (세션 ID 기준) + 닉네임 반환
    public String removeUserBySessionId(String sessionId) {
        User removed = sessionUserMap.remove(sessionId);
        return removed != null ? removed.getNickname() : null;
    }

    // 현재 모든 유저 닉네임 목록
    public List<String> getAllNicknames() {
        List<String> nicknames = new ArrayList<>();
        for (User user : sessionUserMap.values()) {
            nicknames.add(user.getNickname());
        }
        return nicknames;
    }


    // 닉네임 → User 객체 반환
    public Optional<User> getUserByNickname(String nickname) {
        return sessionUserMap.values().stream()
                .filter(user -> user.getNickname().equals(nickname))
                .findFirst();
    }

    // 세션 ID → User 객체 반환
    public Optional<User> getUserBySessionId(String sessionId) {
        return Optional.ofNullable(sessionUserMap.get(sessionId));
    }

    // 현재 유저 수 반환
    public int getUserCount() {
        return sessionUserMap.size();
    }

    // 출제자 설정 (모두 false 후 하나 true)
    public void setDrawer(String nickname) {
        sessionUserMap.values().forEach(user -> user.setDrawer(false));
        getUserByNickname(nickname).ifPresent(user -> user.setDrawer(true));
    }

    // 현재 출제자 반환
    public Optional<String> getCurrentDrawer() {
        return sessionUserMap.values().stream()
                .filter(User::isDrawer)
                .map(User::getNickname)
                .findFirst();
    }

    // 점수 증가
    public void addScore(String nickname, int amount) {
        getUserByNickname(nickname).ifPresent(user -> user.addScore(amount));
    }

    // 전체 유저 정보 Map 제공 (예: 점수판 용도)
    public Map<String, User> getAllUsers() {
        Map<String, User> result = new HashMap<>();
        for (User user : sessionUserMap.values()) {
            result.put(user.getNickname(), user);
        }
        return result;
    }
}
