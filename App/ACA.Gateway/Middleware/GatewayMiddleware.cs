using ACA.Gateway.Configurations;
using ACA.Gateway.Endpoints.Gateway;
using ACA.Gateway.Endpoints.User;
using ACA.Gateway.Handlers;
using ACA.Gateway.Models;
using ACA.Gateway.Providers;
using ACA.Gateway.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.IdentityModel.Logging;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System.Net;
using System.Text;

namespace ACA.Gateway.Middleware
{
    public static class GatewayMiddleware
    {
        public static void AddGateway(this WebApplicationBuilder builder)
        {
            builder.Services
                .AddReverseProxy()
                .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

            var gatewayConfig = builder.Configuration.GetGatewayConfig();
            builder.Services.AddSingleton<GatewayConfig>(gatewayConfig);

            builder.Services.AddSingleton<DiscoveryDocument>(serviceProvider =>
            {
                var discoveryProvider = serviceProvider.GetRequiredService<IDiscoveryProvider>();
                return discoveryProvider.GetDiscoveryDocument().GetAwaiter().GetResult();
            });

            builder.Services.AddHttpClient<IDiscoveryProvider, DiscoveryProvider>();

            builder.Services.AddHttpClient<ITokenRefreshService, TokenRefreshService>();
            builder.Services.AddHttpClient<ITokenExchangeService, AzureAdTokenExchangeService>();

            builder.Services.AddScoped<IHttpRequestService, HttpServiceService>();
            builder.Services.AddScoped<IGatewayService, GatewayService>();
            builder.Services.AddScoped<IApiTokenService, ApiTokenService>();
            builder.Services.AddScoped<ITokenHandler, TokenHandler>();

            builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            builder.Services.AddSession(options => options.IdleTimeout = TimeSpan.FromMinutes(gatewayConfig.SessionTimeoutInMin));
            builder.Services.AddAntiforgery(setup => setup.HeaderName = "X-XSRF-TOKEN");

            builder.AddAuthorization();
            builder.AddAuthentication(gatewayConfig);
        }

        public static void UseGateway(this WebApplication app)
        {
            if (!app.Environment.IsDevelopment())
            {
                app.UseHsts();
            }

            app.UseForwardedHeaders();

            //app.UseHttpsRedirection();    //This is managed by the Azure host
            app.UseStaticFiles();

            app.UseRouting();
            app.UseSession();

            app.UseAuthentication();
            app.UseAuthorization();
            
            app.UseCookiePolicy();
            app.UseXsrfCookie();
            app.UseGatewayEndpoints();
            app.UseYarp();
        }

        private static void AddAuthorization(this WebApplicationBuilder builder)
        {
            builder.Services.AddAuthorization(options =>
            {
                options.AddPolicy("authPolicy", policy =>
                {
                    policy.RequireAuthenticatedUser();
                });
            });
        }

        private static void AddAuthentication(this WebApplicationBuilder builder, GatewayConfig gatewayConfig)
        {
            if (builder.Environment.IsDevelopment())
            {
                IdentityModelEventSource.ShowPII = true;
            }

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
            })
            .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, setup =>
            {
                setup.ExpireTimeSpan = TimeSpan.FromMinutes(gatewayConfig.SessionTimeoutInMin);
                setup.SlidingExpiration = true;

                setup.Cookie.Name = ".aca-app";
                setup.DataProtectionProvider = DataProtectionProvider.Create("yarp-gateway");
            })
            .AddOpenIdConnect(OpenIdConnectDefaults.AuthenticationScheme, options =>
            {
                options.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
                options.Authority = gatewayConfig.Authority;
                options.ClientId = gatewayConfig.ClientId;
                options.UsePkce = true;
                options.ClientSecret = gatewayConfig.ClientSecret;
                options.ResponseType = OpenIdConnectResponseType.Code;
                options.SaveTokens = false;
                options.GetClaimsFromUserInfoEndpoint = gatewayConfig.QueryUserInfoEndpoint;
                options.CorrelationCookie.SecurePolicy = CookieSecurePolicy.Always;
                options.NonceCookie.SecurePolicy = CookieSecurePolicy.Always;
                options.RequireHttpsMetadata = false;

                options.Scope.Clear();
                var scopes = gatewayConfig.Scopes.Split(" ").ToList();
                scopes.ForEach(scope => options.Scope.Add(scope));

                options.TokenValidationParameters = new()
                {
                    NameClaimType = "name",
                    RoleClaimType = "role"
                };

                options.Events.OnAuthenticationFailed = async context =>
                {
                    var result = JsonConvert.SerializeObject(
                        new { Message = $"Authentication failed" },
                        Formatting.Indented,
                        new JsonSerializerSettings
                        {
                            ContractResolver = new CamelCasePropertyNamesContractResolver()
                        });

                    context.Response.ContentType = "application/json";
                    context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;

                    context.Response.ContentLength = result.Length;
                    await context.Response.Body.WriteAsync(Encoding.UTF8.GetBytes(result), 0, result.Length);
                };

                options.Events.OnTokenValidated = context =>
                {
                    var tokenHandler = context.HttpContext.RequestServices.GetRequiredService<ITokenHandler>();
                    tokenHandler.HandleToken(context);
                    return Task.FromResult(0);
                };

                options.Events.OnRedirectToIdentityProviderForSignOut = context =>
                {
                    LogoutHandler.HandleLogout(context, gatewayConfig);
                    return Task.CompletedTask;
                };
            });
        }

        private static void UseForwardedHeaders(this WebApplication app)
        {
            var forwardOpts = new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.All
            };
            //TODO: Set this up to only accept the forwarded headers from the load balancer
            forwardOpts.KnownNetworks.Clear();
            forwardOpts.KnownProxies.Clear();

            app.UseForwardedHeaders(forwardOpts);
        }

        private static void UseGatewayEndpoints(this WebApplication app)
        {
            app.LoginRoute();
            app.LogoutRoute();
            app.UserInfoRoute();
            app.GatewayStatusRoute();
        }

        private static void UseYarp(this WebApplication app)
        {
            app.MapReverseProxy(pipeline =>
            {
                pipeline.UseGatewayPipeline();
            });
        }
    }
}
