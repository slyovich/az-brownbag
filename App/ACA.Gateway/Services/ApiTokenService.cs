using ACA.Gateway.Configurations;
using ACA.Gateway.Models;
using ACA.Gateway.Utils;

namespace ACA.Gateway.Services
{
    public class ApiTokenService : IApiTokenService
    {
        private ITokenExchangeService _tokenExchangeService;
        private readonly IHttpRequestService _httpRequestService;

        public ApiTokenService(
            ITokenExchangeService tokenExchangeService,
            IHttpRequestService httpRequestService)
        {
            _tokenExchangeService = tokenExchangeService;
            _httpRequestService = httpRequestService;
        }

        public void InvalidateApiAccessTokens()
        {
            _httpRequestService.RemoveSessionValue(SessionKeys.API_ACCESS_TOKEN);
        }

        public async Task<string> GetApiAccessToken(ApiConfig apiConfig, string token, string refreshToken)
        {
            var apiToken = GetCachedApiToken(apiConfig);
            if (apiToken != null && !string.IsNullOrEmpty(apiToken.access_token))
            {
                return apiToken.access_token;
            }

            var tokenExchangeResponse = await _tokenExchangeService.GetApiToken(token, refreshToken, apiConfig);
            SetCachedApiToken(apiConfig, tokenExchangeResponse);

            return tokenExchangeResponse.access_token;
        }

        private TokenExchangeResponse? GetCachedApiToken(ApiConfig apiConfig)
        {
            var cache = _httpRequestService.GetSessionValue<Dictionary<string, TokenExchangeResponse>>(SessionKeys.API_ACCESS_TOKEN);
            if (cache == null)
            {
                return null;
            }

            if (!cache.ContainsKey(apiConfig.ApiPath))
            {
                return null;
            }

            return cache[apiConfig.ApiPath];
        }

        private void SetCachedApiToken(ApiConfig apiConfig, TokenExchangeResponse response)
        {
            var cache = _httpRequestService.GetSessionValue<Dictionary<string, TokenExchangeResponse>>(SessionKeys.API_ACCESS_TOKEN);
            if (cache == null)
            {
                cache = new Dictionary<string, TokenExchangeResponse>();
            }

            cache[apiConfig.ApiPath] = response;
            _httpRequestService.SetSessionValue<Dictionary<string, TokenExchangeResponse>>(SessionKeys.API_ACCESS_TOKEN, cache);
        }
    }
}
