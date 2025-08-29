package com.medical.dsa;

import com.medical.model.User;
import java.util.List;
import java.util.ArrayList;

public class Search {
    public static List<User> searchByName(List<User> users, String name) {
        List<User> result = new ArrayList<>();
        for (User user : users) {
            if (user.getFullName().toLowerCase().contains(name.toLowerCase())) {
                result.add(user);
            }
        }
        return result;
    }
} 