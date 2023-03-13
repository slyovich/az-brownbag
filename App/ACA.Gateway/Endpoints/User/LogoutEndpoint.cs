using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace ACA.Gateway.Endpoints.User
{
    public static class LogoutEndpoint
    {
        public static void LogoutRoute(this IEndpointRouteBuilder app)
        {
            app
                .MapGet("/logout", Logout)
                .RequireAuthorization();
        }

        private static IResult Logout(string? redirectUrl, HttpContext httpContext)
        {
            if (string.IsNullOrEmpty(redirectUrl))
            {
                redirectUrl = "/";
            }

            httpContext.Session.Clear();

            var authProps = new AuthenticationProperties
            {
                RedirectUri = redirectUrl
            };

            var authSchemes = new string[] {
                    CookieAuthenticationDefaults.AuthenticationScheme,
                    OpenIdConnectDefaults.AuthenticationScheme
                };

            return Results.SignOut(authProps, authSchemes);
        }
    }
}
