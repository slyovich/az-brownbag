using ACA.Gateway.Configurations;

namespace ACA.Gateway.Endpoints.Gateway
{
    public static class StatusEndpoint
    {
        public static void GatewayStatusRoute(this IEndpointRouteBuilder app)
        {
            app
                .MapGet("/gatewaystatus", GatewayStatus)
                .AllowAnonymous();
        }

        private static IResult GatewayStatus(GatewayConfig gatewayConfig)
        {
            var dict = new Dictionary<string, string>
            {
                    { "version", gatewayConfig.Version }
                };

            return Results.Ok(dict);
        }
    }
}
