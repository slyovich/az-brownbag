using ACA.Gateway.Configurations;
using ACA.Gateway.Models;

namespace ACA.Gateway.Services
{
    public class AzureAdTokenExchangeService : ITokenExchangeService
    {
        private readonly HttpClient _httpClient;
        private readonly DiscoveryDocument _discoveryDocument;
        private readonly GatewayConfig _gatewayConfig;

        public AzureAdTokenExchangeService(HttpClient httpClient, GatewayConfig gatewayConfig, DiscoveryDocument discoveryDocument)
        {
            _discoveryDocument = discoveryDocument;
            _gatewayConfig = gatewayConfig;
            _httpClient = httpClient;
        }

        public async Task<TokenExchangeResponse> GetApiToken(string accessToken, ApiConfig apiConfig)
        {
            var scope = apiConfig.ApiScopes;
            var url = _discoveryDocument.token_endpoint;

            var dict = new Dictionary<string, string>
            {
                ["grant_type"] = "urn:ietf:params:oauth:grant-type:jwt-bearer",
                ["client_id"] = _gatewayConfig.ClientId,
                ["client_secret"] = _gatewayConfig.ClientSecret,
                ["assertion"] = accessToken,
                ["scope"] = scope,
                ["requested_token_use"] = "on_behalf_of"
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