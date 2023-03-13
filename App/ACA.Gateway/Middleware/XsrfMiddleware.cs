using ACA.Gateway.Configurations;
using Microsoft.AspNetCore.Antiforgery;
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json;
using System.Net;
using System.Text;

namespace ACA.Gateway.Middleware
{
    public static class XsrfMiddleware
    {
        public static void UseXsrfCookie(this WebApplication app)
        {
            app.UseXsrfCookieCreator();
            app.UseXsrfCookieChecks();
        }

        private static void UseXsrfCookieCreator(this WebApplication app)
        {
            app.Use(async (ctx, next) =>
            {
                var antiforgery = ctx.RequestServices.GetRequiredService<IAntiforgery>();
                if (antiforgery == null)
                {
                    throw new Exception("IAntiforgery service exptected!");
                }

                var tokens = antiforgery!.GetAndStoreTokens(ctx);
                if (tokens.RequestToken == null)
                {
                    throw new Exception("token exptected!");
                }

                ctx.Response
                    .Cookies
                    .Append(
                        "XSRF-TOKEN",
                        tokens.RequestToken,
                        new CookieOptions() { HttpOnly = false });

                await next(ctx);
            });
        }

        private static void UseXsrfCookieChecks(this WebApplication app)
        {
            app.Use(async (ctx, next) =>
            {
                var gatewayConfig = ctx.RequestServices.GetRequiredService<GatewayConfig>();
                var apiConfigs = gatewayConfig.ApiConfigs;

                var antiforgery = ctx.RequestServices.GetRequiredService<IAntiforgery>();
                if (antiforgery == null)
                {
                    throw new Exception("IAntiforgery service exptected!");
                }

                var currentUrl = ctx.Request.Path.ToString().ToLower();
                if (apiConfigs.Any(c => currentUrl.StartsWith(c.ApiPath)) && !await antiforgery.IsRequestValidAsync(ctx))
                {
                    var result = JsonConvert.SerializeObject(
                        new { Message = $"XSRF token validadation failed" },
                        Formatting.Indented,
                        new JsonSerializerSettings
                        {
                            ContractResolver = new CamelCasePropertyNamesContractResolver()
                        });

                    ctx.Response.ContentType = "application/json";
                    ctx.Response.StatusCode = (int)HttpStatusCode.Unauthorized;

                    ctx.Response.ContentLength = result.Length;
                    await ctx.Response.Body.WriteAsync(Encoding.UTF8.GetBytes(result), 0, result.Length);

                    return;
                }

                await next(ctx);
            });
        }
    }
}
