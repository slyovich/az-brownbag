using ACA.Gateway.Configurations;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;

namespace ACA.Gateway.Handlers
{
    public static class LogoutHandler
    {
        public static void HandleLogout(RedirectContext context, GatewayConfig gatewayConfig)
        {
            if (!string.IsNullOrEmpty(gatewayConfig.LogoutUrl))
            {
                var request = context.Request;
                var gatewayUrl = Uri.EscapeDataString(request.Scheme + "://" + request.Host + request.PathBase);

                var logoutUri = gatewayConfig.LogoutUrl
                                        .Replace("{authority}", gatewayConfig.Authority)
                                        .Replace("{clientId}", gatewayConfig.ClientId)
                                        .Replace("{gatewayUrl}", gatewayUrl);

                context.Response.Redirect(logoutUri);
                context.HandleResponse();
            }
        }
    }
}
