using ACA.Gateway.Models;

namespace ACA.Gateway.Providers
{
    public interface IDiscoveryProvider
    {
        Task<DiscoveryDocument> GetDiscoveryDocument();
    }
}