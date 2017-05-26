public class MMAccountStatus {
    private string error;
    private string originalResponse;
    private string responseType;
    private string smsLimit;
    private string smsRemaining;
    public MMAccountStatus() {
        this.error = '';
        this.originalResponse = '';
        this.responseType = '';
        this.smsLimit = '';
        this.smsRemaining = '';
    }
    public string getError() {
        return this.error;
    }
    public void setError(string error) {
        this.error = error;
    }
    public string getOriginalResponse() {
        return this.originalResponse;
    }
    public void setOriginalResponse(string originalResponse) {
        this.originalResponse = originalResponse;
    }
    public string getResponseType() {
        return this.responseType;
    }
    public void setResponseType(string responseType) {
        this.responseType = responseType;
    }
    public string getSmsLimit() {
        return this.smsLimit;
    }
    public void setSmsLimit(string smsLimit) {
        this.smsLimit = smsLimit;
    }
    public string getSmsRemaining() {    
        return this.smsRemaining;
    }
    public void setSmsRemaining(string smsRemaining) {
        this.smsRemaining = smsRemaining;
    }
}