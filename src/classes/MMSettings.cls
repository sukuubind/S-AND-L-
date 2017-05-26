public class MMSettings {
    private string userId;
    private string password;
    private string dialCode;
    private string notifyTo;
    public MMSettings() {
    }
    public MMSettings(string userId, string password, string dialCode) {
        this.userId = userId;
        this.password = password;
        this.dialCode = dialCode;
    }
    public MMSettings(string userId, string password, string dialCode, string notifyTo) {
        this.userId = userId;
        this.password = password;
        this.dialCode = dialCode;
        this.notifyTo = notifyTo;
    }

    public string getUserId() {
        return this.userId;
    }
    public void setUserId(string userId) {
        this.userId = userId;
    }
    public string getPassword() {
        return this.password;
    }
    public void setPassword(string password) {
        this.password = password;
    }
    public string getDialCode() {
        return this.dialCode;
    }
    public void setDialCode(string dialCode) {
        this.dialCode = dialCode;
    }
    public string getNotifyTo() {
        return this.notifyTo;
    }
    public void setNotifyTo(string notifyTo) {
        this.notifyTo = notifyTo;
    }
}