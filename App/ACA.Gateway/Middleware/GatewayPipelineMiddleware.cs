using ACA.Gateway.Services;

namespace ACA.Gateway.Middleware
{
    public static class GatewayPipelineMiddleware
    {
        public static void UseGatewayPipeline(this IReverseProxyApplicationBuilder pipeline)
        {
            pipeline.Use(async (ctx, next) =>
            {
                var gatewayService = ctx.RequestServices.GetRequiredService<IGatewayService>();
                await gatewayService.TryAddApiAccessToken();

                await next().ConfigureAwait(false);
            });
        }
    }
}
