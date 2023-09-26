using ACA.Gateway.Configurations;
using ACA.Gateway.Models;

namespace ACA.Gateway.Services
{
    public class AzureAdB2CTokenExchangeService : ITokenExchangeService
    {
        private readonly HttpClient _httpClient;
        private readonly DiscoveryDocument _discoveryDocument;
        private readonly GatewayConfig _gatewayConfig;

        public AzureAdB2CTokenExchangeService(HttpClient httpClient, GatewayConfig gatewayConfig, DiscoveryDocument discoveryDocument)
        {
            _discoveryDocument = discoveryDocument;
            _gatewayConfig = gatewayConfig;
            _httpClient = httpClient;
        }

        public async Task<TokenExchangeResponse> GetApiToken(string accessToken, string refreshToken, ApiConfig apiConfig)
        {
            var scope = apiConfig.ApiScopes;
            var url = _discoveryDocument.token_endpoint;

            var dict = new Dictionary<string, string>
            {
                ["grant_type"] = "refresh_token",
                ["client_id"] = _gatewayConfig.ClientId,
                ["client_secret"] = _gatewayConfig.ClientSecret,
                ["scope"] = scope,
                ["refresh_token"] = refreshToken
            };

            var content = new FormUrlEncodedContent(dict);
            var request = new HttpRequestMessage(HttpMethod.Post, url) { Content = content };
            var httpResponse = await _httpClient.SendAsync(request);

            var tokenExchangeResponse = await httpResponse.Content.ReadFromJsonAsync<TokenExchangeResponse>();
            if (tokenExchangeResponse == null)
            {
                throw new Exception("error exchaning token at " + _discoveryDocument.token_endpoint);
            }

            return tokenExchangeResponse;
        }
    }
}