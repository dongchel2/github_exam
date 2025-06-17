package com.example.catchMind.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class catchMindController {

    @PostMapping("/usr/home/game")
    public String startGame(@RequestParam String nickname, Model model) {

    	
//      참여자 VS 출제자 판별(1)
        boolean isDrawer = "출제자".equals(nickname); 
        model.addAttribute("nickname", nickname);
        model.addAttribute("isDrawer", isDrawer);

        
//  일단 그림그리기 스타트를 출제자로만 들어가야 그림을 그릴수 있는 문제가 발생 
//  <--   추후  해결하기  --> 
        return "usr/home/game"; 
    }
    
    
}
