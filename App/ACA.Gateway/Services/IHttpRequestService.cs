using ACA.Gateway.Configurations;

namespace ACA.Gateway.Services
{
    public interface IHttpRequestService
    {
        string? GetSessionValue(string sessionKey);
        T? GetSessionValue<T>(string sessionKey);
        
        void SetSessionValue(string sessionKey, string value);
        void SetSessionValue<T>(string sessionKey, T value);

        void RemoveSessionValue(string sessionKey);

        ApiConfig? GetApiConfig();

        void AddHeader(string key, string value);
    }
}