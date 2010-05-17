package org.comics.search.pojo;

import java.util.Date;

public class Publisher {
    private Integer brandCount;
    private Country country;
    private Date created;
    private Integer id;
    private Integer imprintCount;
    private Integer indiciaPublisherCount;
    private Boolean isMaster;
    private Integer issueCount;
    private Date modified;
    private String name;
    private String notes;
    private Publisher parentPublisher;
    private Boolean reserved;
    private Integer seriesCount;
    private String url;
    private Integer yearBegan;
    private Integer yearEnded;

    public Integer getBrandCount() {
        return brandCount;
    }

    public Country getCountry() {
        return country;
    }

    public Date getCreated() {
        return created;
    }

    public Integer getId() {
        return id;
    }

    public Integer getImprintCount() {
        return imprintCount;
    }

    public Integer getIndiciaPublisherCount() {
        return indiciaPublisherCount;
    }

    public Boolean getIsMaster() {
        return isMaster;
    }

    public Integer getIssueCount() {
        return issueCount;
    }

    public Date getModified() {
        return modified;
    }

    public String getName() {
        return name;
    }

    public String getNotes() {
        return notes;
    }

    public Publisher getParentPublisher() {
        return parentPublisher;
    }

    public Boolean getReserved() {
        return reserved;
    }

    public Integer getSeriesCount() {
        return seriesCount;
    }

    public String getUrl() {
        return url;
    }

    public Integer getYearBegan() {
        return yearBegan;
    }

    public Integer getYearEnded() {
        return yearEnded;
    }

    public void setBrandCount(Integer brandCount) {
        this.brandCount = brandCount;
    }

    public void setCountry(Country country) {
        this.country = country;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setImprintCount(Integer imprintCount) {
        this.imprintCount = imprintCount;
    }

    public void setIndiciaPublisherCount(Integer indiciaPublisherCount) {
        this.indiciaPublisherCount = indiciaPublisherCount;
    }

    public void setIsMaster(Boolean isMaster) {
        this.isMaster = isMaster;
    }

    public void setIssueCount(Integer issueCount) {
        this.issueCount = issueCount;
    }

    public void setModified(Date modified) {
        this.modified = modified;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void setParentPublisher(Publisher parentPublisher) {
        this.parentPublisher = parentPublisher;
    }

    public void setReserved(Boolean reserved) {
        this.reserved = reserved;
    }

    public void setSeriesCount(Integer seriesCount) {
        this.seriesCount = seriesCount;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public void setYearBegan(Integer yearBegan) {
        this.yearBegan = yearBegan;
    }

    public void setYearEnded(Integer yearEnded) {
        this.yearEnded = yearEnded;
    }

}
