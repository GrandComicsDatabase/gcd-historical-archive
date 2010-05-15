package org.comics.search.pojo;

import java.util.Date;

public class IndiciaPublisher {

	private Country country;
	private Date created;
	private Integer id;
	private Integer issueCount;
	private Boolean isSurrogate;
	private Date modified;
	private String name;
	private String notes;
	private IndiciaPublisher parentIndiciaPublisher;
	private String url;
	private Integer yearBegan;
	private Integer yearEnded;

	public Country getCountry() {
		return country;
	}

	public Date getCreated() {
		return created;
	}

	public Integer getId() {
		return id;
	}

	public Integer getIssueCount() {
		return issueCount;
	}

	public Boolean getIsSurrogate() {
		return isSurrogate;
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

	public IndiciaPublisher getParentIndiciaPublisher() {
		return parentIndiciaPublisher;
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

	public void setCountry(Country country) {
		this.country = country;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public void setIssueCount(Integer issueCount) {
		this.issueCount = issueCount;
	}

	public void setIsSurrogate(Boolean isSurrogate) {
		this.isSurrogate = isSurrogate;
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

	public void setParentIndiciaPublisher(
			IndiciaPublisher parentIndiciaPublisher) {
		this.parentIndiciaPublisher = parentIndiciaPublisher;
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
