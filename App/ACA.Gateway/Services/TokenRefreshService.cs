using ACA.Gateway.Configurations;
using ACA.Gateway.Models;
using ACA.Gateway.Utils;

namespace ACA.Gateway.Services
{
    public class TokenRefreshService : ITokenRefreshService
    {
        private readonly IHttpRequestService _httpRequestService;
        private readonly HttpClient _httpClient;
        private readonly GatewayConfig _gatewayConfig;
        private readonly DiscoveryDocument _discoveryDocument;

        public TokenRefreshService(
            IHttpRequestService httpRequestService,
            HttpClient httpClient,
            GatewayConfig gatewayConfig,
            DiscoveryDocument discoveryDocument)
        {
            _httpRequestService = httpRequestService;
            _httpClient = httpClient;
            _gatewayConfig = gatewayConfig;
            _discoveryDocument = discoveryDocument;
        }

        public async Task<RefreshResponse?> RefreshAsync()
        {
            var refreshToken = GetCachedRefreshToken();

            var payload = new Dictionary<string, string>
            {
                { "grant_type", "refresh_token" },
                { "refresh_token", refreshToken },
                { "client_id", _gatewayConfig.ClientId },
                { "client_secret", _gatewayConfig.ClientSecret }
            };

            var request = new HttpRequestMessage
            {
                RequestUri = new Uri(_discoveryDocument.token_endpoint),
                Method = HttpMethod.Post,
                Content = new FormUrlEncodedContent(payload)
            };

            var response = await _httpClient.SendAsync(request);
            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            var refreshResponse = await response.Content.ReadFromJsonAsync<RefreshResponse>();
            var expiresAt = new DateTimeOffset(DateTime.Now).AddSeconds(Convert.ToInt32(refreshResponse.expires));

            _httpRequestService.SetSessionValue(SessionKeys.ACCESS_TOKEN, refreshResponse.access_token);
            _httpRequestService.SetSessionValue(SessionKeys.ID_TOKEN, refreshResponse.id_token);
            _httpRequestService.SetSessionValue(SessionKeys.REFRESH_TOKEN, refreshResponse.refresh_token);
            _httpRequestService.SetSessionValue(SessionKeys.EXPIRES_AT, $"{expiresAt.ToUnixTimeSeconds()}");

            return refreshResponse;
        }

        public bool IsTokenExpired()
        {
            var expiresAt = Convert.ToInt64(_httpRequestService.GetSessionValue(SessionKeys.EXPIRES_AT)) - 30;
            var now = new DateTimeOffset(DateTime.Now).ToUnixTimeSeconds();

            var expired = now >= expiresAt;
            return expired;
        }

        public bool HasCachedRefreshToken()
        {
            var refreshToken = _httpRequestService.GetSessionValue(SessionKeys.REFRESH_TOKEN);
            return !string.IsNullOrEmpty(refreshToken);
        }

        private string GetCachedRefreshToken()
        {
            var refreshToken = _httpRequestService.GetSessionValue(SessionKeys.REFRESH_TOKEN);
            return refreshToken ?? "";
        }
    }
}