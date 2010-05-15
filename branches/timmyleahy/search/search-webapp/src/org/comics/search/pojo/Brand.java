package org.comics.search.pojo;

import java.util.Date;

public class Brand {
	private Date created;
	private Integer id;
	private Integer issueCount;
	private Date modified;
	private String name;
	private String notes;
	private Brand parentBrand;
	private Boolean reserved;
	private String url;
	private Integer yearBegan;
	private Integer yearEnded;

	public Date getCreated() {
		return created;
	}

	public Integer getId() {
		return id;
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

	public Brand getParentBrand() {
		return parentBrand;
	}

	public Boolean getReserved() {
		return reserved;
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

	public void setCreated(Date created) {
		this.created = created;
	}

	public void setId(Integer id) {
		this.id = id;
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

	public void setParentBrand(Brand parentBrand) {
		this.parentBrand = parentBrand;
	}

	public void setReserved(Boolean reserved) {
		this.reserved = reserved;
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
