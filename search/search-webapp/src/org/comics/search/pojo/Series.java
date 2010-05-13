package org.comics.search.pojo;

import java.util.Date;

public class Series {
	private Country country;
	private Date created;
	private Issue firstIssue;
	private String format;
	private Boolean hasGallery;
	private Integer id;
	private Integer imprintId;
	private Boolean isCurrent;
	private Integer issueCount;
	private Language language;
	private Issue lastIssue;
	private Date modified;
	private String name;
	private String notes;
	private Integer openReserve;
	private String publicationDates;
	private Publisher publisher;
	private String trackingNotes;
	private Integer yearBegan;
	private Integer yearEnded;

	public Country getCountry() {
		return country;
	}

	public Date getCreated() {
		return created;
	}

	public Issue getFirstIssue() {
		return firstIssue;
	}

	public String getFormat() {
		return format;
	}

	public Boolean getHasGallery() {
		return hasGallery;
	}

	public Integer getId() {
		return id;
	}

	public Integer getImprintId() {
		return imprintId;
	}

	public Boolean getIsCurrent() {
		return isCurrent;
	}

	public Integer getIssueCount() {
		return issueCount;
	}

	public Language getLanguage() {
		return language;
	}

	public Issue getLastIssue() {
		return lastIssue;
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

	public Integer getOpenReserve() {
		return openReserve;
	}

	public String getPublicationDates() {
		return publicationDates;
	}

	public Publisher getPublisher() {
		return publisher;
	}

	public String getTrackingNotes() {
		return trackingNotes;
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

	public void setFirstIssue(Issue firstIssue) {
		this.firstIssue = firstIssue;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public void setHasGallery(Boolean hasGallery) {
		this.hasGallery = hasGallery;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public void setImprintId(Integer imprintId) {
		this.imprintId = imprintId;
	}

	public void setIsCurrent(Boolean isCurrent) {
		this.isCurrent = isCurrent;
	}

	public void setIssueCount(Integer issueCount) {
		this.issueCount = issueCount;
	}

	public void setLanguage(Language language) {
		this.language = language;
	}

	public void setLastIssue(Issue lastIssue) {
		this.lastIssue = lastIssue;
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

	public void setOpenReserve(Integer openReserve) {
		this.openReserve = openReserve;
	}

	public void setPublicationDates(String publicationDates) {
		this.publicationDates = publicationDates;
	}

	public void setPublisher(Publisher publisher) {
		this.publisher = publisher;
	}

	public void setTrackingNotes(String trackingNotes) {
		this.trackingNotes = trackingNotes;
	}

	public void setYearBegan(Integer yearBegan) {
		this.yearBegan = yearBegan;
	}

	public void setYearEnded(Integer yearEnded) {
		this.yearEnded = yearEnded;
	}

}
