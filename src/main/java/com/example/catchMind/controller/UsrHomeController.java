package com.example.catchMind.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UsrHomeController {

    @GetMapping("/")
    public String showHome() {
        return "usr/home/main";  
    }


	@GetMapping("/usr/home/main")
	public String main() {

		return "usr/home/main";

	}
    
    
	@GetMapping("/usr/home/catchMind")
	public String catchMind() {
	
		return "usr/home/catchMind";
	
	}



	
	
}