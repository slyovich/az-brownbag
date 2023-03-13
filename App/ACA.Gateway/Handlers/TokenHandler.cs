using ACA.Gateway.Services;
using ACA.Gateway.Utils;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;

namespace ACA.Gateway.Handlers
{
    public class TokenHandler : ITokenHandler
    {
        private readonly IHttpRequestService _httpRequestService;

        public TokenHandler(IHttpRequestService httpRequestService)
        {
            _httpRequestService = httpRequestService;
        }

        public void HandleToken(TokenValidatedContext context)
        {
            if (context.TokenEndpointResponse == null)
            {
                throw new Exception("TokenEndpointResponse expected!");
            }

            var accessToken = context.TokenEndpointResponse.AccessToken;
            var idToken = context.TokenEndpointResponse.IdToken;
            var refreshToken = context.TokenEndpointResponse.RefreshToken;
            var expiresIn = context.TokenEndpointResponse.ExpiresIn;
            var expiresAt = new DateTimeOffset(DateTime.Now).AddSeconds(Convert.ToInt32(expiresIn));

            _httpRequestService.SetSessionValue(SessionKeys.ACCESS_TOKEN, accessToken);
            _httpRequestService.SetSessionValue(SessionKeys.ID_TOKEN, idToken);
            _httpRequestService.SetSessionValue(SessionKeys.REFRESH_TOKEN, refreshToken);
            _httpRequestService.SetSessionValue(SessionKeys.EXPIRES_AT, $"{expiresAt.ToUnixTimeSeconds()}");
        }
    }
}
