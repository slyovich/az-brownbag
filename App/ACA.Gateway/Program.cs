using ACA.Gateway.Middleware;
using System.IdentityModel.Tokens.Jwt;

// Disable claim mapping to get claims 1:1 from the tokens
JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();

var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddDistributedMemoryCache();
}
else
{
    builder.Services.AddStackExchangeRedisCache(options =>
    {
        options.Configuration = builder.Configuration.GetValue<string>("Redis:ConnectionString");
        options.InstanceName = builder.Configuration.GetValue<string>("Redis:InstanceName");
    });
}

builder.AddGateway();

var app = builder.Build();
app.UseGateway();
app.Run();
