public class MMUtilSMSObject {
    private string entityId;
    private string selectedPhone;
    private long receiptNumber;
    private boolean isTrack;
    private string country;
    private string message;
    private string entityType;
    private string timeZone;
    private string receiptOwnerId;
    
    public MMUtilSMSObject() {
    }
    public MMUtilSMSObject(string entityId, string selectedPhone, long receiptNumber, boolean isTrack, string country, String message) {
        this.entityId = entityId;
        this.selectedPhone = selectedPhone;
        this.receiptNumber = receiptNumber;
        this.isTrack = isTrack;
        this.country = country;
        this.message = message;
    }
    public MMUtilSMSObject(string entityId, string selectedPhone, long receiptNumber, boolean isTrack, string country, String message, string receiptOwnerId) {
        this.entityId = entityId;
        this.selectedPhone = selectedPhone;
        this.receiptNumber = receiptNumber;
        this.isTrack = isTrack;
        this.country = country;
        this.message = message;
        this.receiptOwnerId = receiptOwnerId;
    }
    public MMUtilSMSObject(string entityId, string selectedPhone, long receiptNumber, boolean isTrack, string country, String message, string entityType, string timeZone) {
        this.entityId = entityId;
        this.selectedPhone = selectedPhone;
        this.receiptNumber = receiptNumber;
        this.isTrack = isTrack;
        this.country = country;
        this.message = message;
        this.entityType = entityType;
        this.timeZone = timeZone;
    }
    public MMUtilSMSObject(string entityId, string selectedPhone, long receiptNumber, boolean isTrack, string country, String message, string entityType, string timeZone, string receiptOwnerId) {
        this.entityId = entityId;
        this.selectedPhone = selectedPhone;
        this.receiptNumber = receiptNumber;
        this.isTrack = isTrack;
        this.country = country;
        this.message = message;
        this.entityType = entityType;
        this.timeZone = timeZone;
        this.receiptOwnerId = receiptOwnerId;
    }
    public string getEntityId() {
        return this.entityId;
    }
    public void setEntityId(string entityId) {
        this.entityId = entityId;
    }
    public string getSelectedPhone() {
        return this.selectedPhone;
    }
    public void setSelectedPhone(string selectedPhone) {
        this.selectedPhone = selectedPhone;
    }
    public long getReceiptNumber() {
        return this.receiptNumber;
    }
    public void setReceiptNumber(long receiptNumber) {
        this.receiptNumber = receiptNumber;
    }
    public boolean getIsTrack() {
        return this.isTrack;
    }
    public void setIsTrack(boolean isTrack){
        this.isTrack = isTrack;
    }
    public string getCountry() {
        return this.country;
    }
    public void setCountry(string country) {
        this.country = country;
    }
    public String getMessage() {
        return this.message;
    }
    public void setMessage(string message) {
        this.message = message;
    }
    public string getEntityType() {
        return this.entityType;
    }
    public void setEntityType(string entityType) {
        this.entityType = entityType;
    }
    public string getTimeZone() {
        return this.timeZone;
    }
    public void setTimeZone(string timeZone) {
        this.timeZone = timeZone;
    }
    public string getReceiptOwnerId() {
        return this.receiptOwnerId;
    }
    public void setReceiptOwnerId(string receiptOwnerId) {
        this.receiptOwnerId = receiptOwnerId;
    }
}