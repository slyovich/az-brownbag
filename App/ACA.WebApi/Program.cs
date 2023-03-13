using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.Resource;
using Newtonsoft.Json.Serialization;
using Newtonsoft.Json;
using System.Net;
using System.Text;
using Microsoft.IdentityModel.Logging;

var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsDevelopment())
{
    IdentityModelEventSource.ShowPII = true;
}

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    //.AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAd"));
    .AddMicrosoftIdentityWebApi(
        configureJwtBearerOptions =>
        {
            var configuration = builder.Configuration;

            configureJwtBearerOptions.Authority = $"https://login.microsoftonline.com/{configuration["AzureAd:TenantId"]}/v2.0/";
            configureJwtBearerOptions.Audience = $"api://{configuration["AzureAd:ClientId"]}";
            configureJwtBearerOptions.Events = new JwtBearerEvents
            {
                OnAuthenticationFailed = async context =>
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
                }
            };
        },
        configureMicrosoftIdentityOptions =>
        {
            var configuration = builder.Configuration;

            configureMicrosoftIdentityOptions.TenantId = configuration["AzureAd:TenantId"];
            configureMicrosoftIdentityOptions.ClientId = configuration["AzureAd:ClientId"];
            configureMicrosoftIdentityOptions.Instance = configuration["AzureAd:Instance"];
            configureMicrosoftIdentityOptions.Domain = configuration["AzureAd:Domain"];
            configureMicrosoftIdentityOptions.CallbackPath = configuration["AzureAd:CallbackPath"];
        }
    );
builder.Services.AddAuthorization();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();    //This is managed by the Azure host

app.UseAuthentication();
app.UseAuthorization();

var scopeRequiredByApi = app.Configuration["AzureAd:Scopes"] ?? "";
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", (HttpContext httpContext) =>
{
    httpContext.VerifyUserHasAnyAcceptedScope(scopeRequiredByApi);

    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateTime.Now.AddDays(index),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.RequireAuthorization();

app.Run();

internal record WeatherForecast(DateTime Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
