using ACA.Gateway.Configurations;

namespace ACA.Gateway.Services
{
    public interface IApiTokenService
    {
        void InvalidateApiAccessTokens();
        Task<string> GetApiAccessToken(ApiConfig apiConfig, string token);
    }
}