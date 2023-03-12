using ACA.Gateway.Configurations;
using System.Text.Json;

namespace ACA.Gateway.Services
{
    public class HttpServiceService : IHttpRequestService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly GatewayConfig _gatewayConfig;

        public HttpServiceService(IHttpContextAccessor httpContextAccessor, GatewayConfig gatewayConfig)
        {
            _httpContextAccessor = httpContextAccessor;
            _gatewayConfig = gatewayConfig;
        }

        public string? GetSessionValue(string sessionKey)
        {
            return _httpContextAccessor.HttpContext?.Session.GetString(sessionKey);
        }

        public T? GetSessionValue<T>(string sessionKey)
        {
            var stringValue = GetSessionValue(sessionKey);
            if (string.IsNullOrEmpty(stringValue))
            {
                return default;
            }

            return JsonSerializer.Deserialize<T>(stringValue);
        }

        public void SetSessionValue(string sessionKey, string value)
        {
            _httpContextAccessor.HttpContext?.Session.SetString(sessionKey, value);
        }

        public void SetSessionValue<T>(string sessionKey, T value)
        {
            var json = JsonSerializer.Serialize(value);
            SetSessionValue(sessionKey, json);
        }

        public void RemoveSessionValue(string sessionKey)
        {
            _httpContextAccessor.HttpContext?.Session.Remove(sessionKey);
        }

        public ApiConfig? GetApiConfig()
        {
            var currentUrl = _httpContextAccessor.HttpContext?.Request.Path.ToString().ToLower();
            
            return 
                string.IsNullOrEmpty(currentUrl)
                    ? null
                    : _gatewayConfig.ApiConfigs.FirstOrDefault(c => currentUrl.StartsWith(c.ApiPath));
        }

        public void AddHeader(string key, string value)
        {
            _httpContextAccessor.HttpContext?.Request.Headers.Add(key, value);
        }
    }
}