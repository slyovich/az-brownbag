using ACA.Gateway.Configurations;
using ACA.Gateway.Utils;

namespace ACA.Gateway.Services
{
    public class GatewayService : IGatewayService
    {
        private readonly ITokenRefreshService _tokenRefreshService;
        private readonly IApiTokenService _apiTokenService;
        private readonly IHttpRequestService _httpRequestService;
        
        public GatewayService(
            ITokenRefreshService tokenRefreshService,
            IApiTokenService apiTokenService,
            IHttpRequestService httpRequestService)
        {
            _tokenRefreshService = tokenRefreshService;
            _apiTokenService = apiTokenService;
            _httpRequestService = httpRequestService;
        }

        public async Task TryAddApiAccessToken()
        {
            if (_tokenRefreshService.IsTokenExpired() && _tokenRefreshService.HasCachedRefreshToken())
            {
                _apiTokenService.InvalidateApiAccessTokens();
                await _tokenRefreshService.RefreshAsync();
            }

            var token = _httpRequestService.GetSessionValue(SessionKeys.ACCESS_TOKEN);
            var refreshToken = _httpRequestService.GetSessionValue(SessionKeys.REFRESH_TOKEN);
            var apiConfig = _httpRequestService.GetApiConfig();

            if (!string.IsNullOrEmpty(token) && apiConfig != null)
            {
                var apiAccessToken = await GetApiAccessToken(token, refreshToken, apiConfig);
                _httpRequestService.AddHeader("Authorization", $"Bearer {apiAccessToken}");
            }
        }

        private async Task<string> GetApiAccessToken(string token, string refreshToken, ApiConfig? apiConfig)
        {
            string? apiToken = null;
            if (!string.IsNullOrEmpty(apiConfig?.ApiScopes) || !string.IsNullOrEmpty(apiConfig?.ApiAudience))
            {
                apiToken = await _apiTokenService.GetApiAccessToken(apiConfig, token, refreshToken);
            }

            if (!string.IsNullOrEmpty(apiToken))
            {
                return apiToken;
            }
            else
            {
                return token;
            }
        }
    }
}
