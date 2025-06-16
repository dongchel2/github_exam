package com.example.catchMind.service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;

@Component
public class UserSessionManager {

    // ✅ 중복 없이 한 번만 선언
    private final Map<String, String> sessionNicknameMap = new ConcurrentHashMap<>();

    // 유저 등록
    public void addUser(String sessionId, String nickname) {
        sessionNicknameMap.put(sessionId, nickname);
    }

    // 유저 제거 및 nickname 반환
    public String removeUserBySessionId(String sessionId) {
        return sessionNicknameMap.remove(sessionId);
    }

    // 전체 닉네임 목록 반환 (유저 목록 조회 메서드?)
    public List<String> getAllNicknames() {
        return new ArrayList<>(sessionNicknameMap.values());
    }
    
    
	 // 중복 닉네임 체크

    public boolean isNicknameExists(String nickname) {
        return sessionNicknameMap.containsValue(nickname);
    }

    
    
    
}
