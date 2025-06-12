package com.example.catchMind.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.catchMind.dto.CatchMindMessage;

@Controller
public class WebSocketController {

	
	
    private final SimpMessagingTemplate messagingTemplate;
   
    
//   정답 주제 설정
    private String answer = null;
    private boolean answered = false;

    public WebSocketController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    
    
//  게임 내 문자메세지 출력 메서드   
    @MessageMapping("/game/send")
    public void handleMessage(@Payload CatchMindMessage message) {
        if ("DRAW".equals(message.getType())) {
            messagingTemplate.convertAndSend("/topic/draw", message);
        } else if ("CHAT".equals(message.getType())) {
            String msg = message.getContent().trim().toLowerCase();

            // 정답 체크
            if (answer != null && !answered && answer.equals(msg)) {
                answered = true;

                CatchMindMessage correctMsg = new CatchMindMessage();
                correctMsg.setType("SYSTEM");
                correctMsg.setSender("시스템");
                correctMsg.setContent(message.getSender() + "님이 정답을 맞췄습니다! 🎉");

                messagingTemplate.convertAndSend("/topic/game", correctMsg);
            } else {
                // 일반 채팅
                messagingTemplate.convertAndSend("/topic/game", message);
            }
        }
    }

    
    
    @MessageMapping("/game/setAnswer")
    public void setAnswer(@Payload CatchMindMessage message) {
        this.answer = message.getContent().trim().toLowerCase();  // 정답 단어 저장
        this.answered = false;

        System.out.println(" 정답 단어 설정됨: " + this.answer);
    }
}
