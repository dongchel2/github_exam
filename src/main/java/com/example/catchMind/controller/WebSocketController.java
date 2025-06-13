package com.example.catchMind.controller;

import java.util.ArrayList;
import java.util.List;

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
	    	
	    	System.out.println("수신된 채팅 메시지: sender=" + message.getSender() + ", content=" + message.getContent());
	
	    	
	        String msg = message.getContent().trim().toLowerCase();
	
	        // 정답 체크
	        if (answer != null && !answered && answer.equals(msg)) {
	            answered = true;
	
	            CatchMindMessage correctMsg = new CatchMindMessage();
	            correctMsg.setType("SYSTEM");
	            correctMsg.setSender("시스템");
	            correctMsg.setContent(message.getSender() + "님이 정답을 맞췄습니다!");
	 
	                messagingTemplate.convertAndSend("/topic/game", correctMsg);
	        } else {
	            // 일반 채팅
	            messagingTemplate.convertAndSend("/topic/game", message);
	        }
	    }
	}
	
	
	//정답 단어 저장 메서드
	@MessageMapping("/game/setAnswer")
	public void setAnswer(@Payload CatchMindMessage message) {
	    this.answer = message.getContent().trim().toLowerCase();  
	    this.answered = false;
	
	    System.out.println(" 정답 단어 설정됨: " + this.answer);
	    }




//서버에서 출제자 순환 처리 기능
	private List<String> players = new ArrayList<>(); // 게임 참가자 닉네임
	private int currentDrawerIndex = 0;
	
	@MessageMapping("/game/join")
	public void joinGame(@Payload CatchMindMessage message) {
	    if (!players.contains(message.getSender())) {
	        players.add(message.getSender());
	    }
	}
	
	// 출제자 교체
	@MessageMapping("/game/changeDrawer")
	public void changeDrawer(@Payload CatchMindMessage message) {
	    if (players.isEmpty()) return;
	
	    currentDrawerIndex = (currentDrawerIndex + 1) % players.size();
	    String nextDrawer = players.get(currentDrawerIndex);
	
	    CatchMindMessage drawerMsg = new CatchMindMessage();
	    drawerMsg.setType("SYSTEM");
	    drawerMsg.setSender("시스템");
	    drawerMsg.setContent("다음 출제자는 " + nextDrawer + "입니다! ✏️");
	
	    messagingTemplate.convertAndSend("/topic/game", drawerMsg);
	
	    // 추가로 클라이언트에게 출제자 여부 통지할 수 있음
	}




}
