public with sharing class SRPEmployerWrapper {
	
	public String EmployerName {get; set;}
	public String EmploymentStatus {get; set;}
	public String title {get; set;}
	public String YearsWorkExp {get; set;}
	
	public SRPEmployerWrapper(String eName, String eTitle){
		EmployerName = eName;
		Title = eTitle;
	}
	
}