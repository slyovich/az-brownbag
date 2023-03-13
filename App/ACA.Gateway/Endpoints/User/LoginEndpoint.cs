using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authentication;

namespace ACA.Gateway.Endpoints.User
{
    public static class LoginEndpoint
    {
        public static void LoginRoute(this IEndpointRouteBuilder app)
        {
            app
                .MapGet("/login", LoginAsync)
                .AllowAnonymous();
        }

        private static async Task LoginAsync(string? redirectUrl, HttpContext httpContext)
        {
            if (string.IsNullOrEmpty(redirectUrl))
            {
                redirectUrl = "/";
            }

            await httpContext.ChallengeAsync(
                OpenIdConnectDefaults.AuthenticationScheme,
                new AuthenticationProperties
                {
                    RedirectUri = redirectUrl
                });
        }
    }
}
