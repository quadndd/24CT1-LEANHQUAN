package com.example.cnpm24ct1.data.model;

import java.io.Serializable;

public class TimelineNode implements Serializable {
    private String title;
    private String description;
    private String timestamp;
    private boolean isCompleted;
    private boolean isCurrent;

    public TimelineNode() {
    }

    public TimelineNode(String title, String description, String timestamp, boolean isCompleted, boolean isCurrent) {
        this.title = title;
        this.description = description;
        this.timestamp = timestamp;
        this.isCompleted = isCompleted;
        this.isCurrent = isCurrent;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public boolean isCompleted() {
        return isCompleted;
    }

    public void setCompleted(boolean completed) {
        isCompleted = completed;
    }

    public boolean isCurrent() {
        return isCurrent;
    }

    public void setCurrent(boolean current) {
        isCurrent = current;
    }
}
