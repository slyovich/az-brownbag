using ACA.Gateway.Configurations;
using ACA.Gateway.Models;
using ACA.Gateway.Utils;

namespace ACA.Gateway.Providers
{
    public class DiscoveryProvider : IDiscoveryProvider
    {
        private readonly string _discoUrl = ".well-known/openid-configuration";
        private readonly HttpClient _httpClient;
        private readonly GatewayConfig _gatewayConfig;

        public DiscoveryProvider(HttpClient httpClient, GatewayConfig gatewayConfig)
        {
            _httpClient = httpClient;
            _gatewayConfig = gatewayConfig;
        }

        public async Task<DiscoveryDocument> GetDiscoveryDocument()
        {
            var url = UrlUtils.CombineUrls(_gatewayConfig.Authority, _discoUrl);

            var discoDocument = await _httpClient.GetFromJsonAsync<DiscoveryDocument>(url);
            if (discoDocument == null)
            {
                throw new Exception("error loading discovery document from " + url);
            }

            return discoDocument;
        }
    }
}
