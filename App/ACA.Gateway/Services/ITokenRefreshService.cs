using ACA.Gateway.Models;

namespace ACA.Gateway.Services
{
    public interface ITokenRefreshService
    {
        Task<RefreshResponse?> RefreshAsync();

        bool IsTokenExpired();
        bool HasCachedRefreshToken();
    }
}