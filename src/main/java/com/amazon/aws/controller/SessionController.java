package com.amazon.aws.controller;

import org.springframework.lang.NonNull;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

import static java.util.Arrays.asList;

@Controller
public class SessionController {

    private static final String SESSION_MESSAGES = "SESSION_MESSAGES";

    @GetMapping("/")
    public String home(Model model, HttpSession session) {
        @SuppressWarnings("unchecked")
        List<String> messages = (List<String>) session.getAttribute(SESSION_MESSAGES);

        if (messages == null) {
            messages = new ArrayList<>();
        }
        model.addAttribute("sessionMessages", messages);
        model.addAttribute("sessionId", session.getId());

        return "index";
    }

    @PostMapping("/persistMessage")
    public String persistMessage(@NonNull @RequestParam("message") String message, HttpServletRequest request) {
        @SuppressWarnings("unchecked")
        List<String> messages = (List<String>) request.getSession().getAttribute(SESSION_MESSAGES);
        if (messages == null) {
            messages = new ArrayList<>(asList(message));
            request.getSession().setAttribute(SESSION_MESSAGES, messages);
        } else {
            messages.add(message);
            request.getSession().setAttribute(SESSION_MESSAGES, messages);
        }
        return "redirect:/";
    }

    @PostMapping("/destroy")
    public String destroySession(HttpServletRequest request) {
        request.getSession().invalidate();
        return "redirect:/";
    }
}