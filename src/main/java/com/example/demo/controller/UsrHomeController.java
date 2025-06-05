package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class UsrHomeController {
	
	
	@GetMapping("/usr/home/catchMind")
	public String catchMind() {

		return "usr/home/catchMind";

	}
	

	@GetMapping("/")
	public String showRoot() {
		return "redirect:/usr/home/catchMind";
	}
	

	
}