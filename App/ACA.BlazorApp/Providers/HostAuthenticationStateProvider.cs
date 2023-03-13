using Microsoft.AspNetCore.Components.Authorization;
using System.Net.Http.Json;
using System.Security.Claims;

namespace ACA.BlazorApp.Providers
{
    public class HostAuthenticationStateProvider : AuthenticationStateProvider
    {
        private static readonly TimeSpan _userCacheRefreshInterval = TimeSpan.FromSeconds(60);

        private readonly HttpClient _client;
        private readonly ILogger<HostAuthenticationStateProvider> _logger;

        private DateTimeOffset _userLastCheck = DateTimeOffset.FromUnixTimeSeconds(0);
        private ClaimsPrincipal _cachedUser = new(new ClaimsIdentity());

        public HostAuthenticationStateProvider(HttpClient httpClient, ILogger<HostAuthenticationStateProvider> logger)
        {
            _client = httpClient;
            _logger = logger;
        }

        public override async Task<AuthenticationState> GetAuthenticationStateAsync() => new AuthenticationState(await GetUser(useCache: true));

        private async ValueTask<ClaimsPrincipal> GetUser(bool useCache = false)
        {
            var now = DateTimeOffset.Now;
            if (useCache && now < _userLastCheck + _userCacheRefreshInterval)
            {
                _logger.LogDebug("Taking user from cache");
                return _cachedUser;
            }

            _logger.LogDebug("Fetching user");
            _cachedUser = await FetchUser();
            _userLastCheck = now;

            return _cachedUser;
        }

        private async Task<ClaimsPrincipal> FetchUser()
        {
            Dictionary<string, string>? userInfo = null;

            try
            {
                userInfo = await _client.GetFromJsonAsync<Dictionary<string, string>>("/userinfo");
            }
            catch (Exception exc)
            {
                _logger.LogWarning(exc, "Fetching user failed.");
            }

            if (userInfo == null)
            {
                return new ClaimsPrincipal(new ClaimsIdentity());
            }

            var identity = new ClaimsIdentity(
                nameof(HostAuthenticationStateProvider),
                "name",
                "role");

            if (userInfo != null)
            {
                foreach (var claim in userInfo)
                {
                    identity.AddClaim(new Claim(claim.Key, claim.Value));
                }
            }

            return new ClaimsPrincipal(identity);
        }
    }
}
