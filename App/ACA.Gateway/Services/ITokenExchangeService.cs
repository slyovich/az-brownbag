using ACA.Gateway.Configurations;
using ACA.Gateway.Models;

namespace ACA.Gateway.Services
{
    public interface ITokenExchangeService
    {
        Task<TokenExchangeResponse> GetApiToken(string accessToken, ApiConfig apiConfig);
    }
}