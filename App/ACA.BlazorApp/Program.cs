using ACA.BlazorApp;
using ACA.BlazorApp.Handlers;
using ACA.BlazorApp.Providers;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddScoped<IAuthenticationProvider, AuthenticationProvider>();
builder.Services.AddScoped<HostAuthenticationStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<HostAuthenticationStateProvider>());
builder.Services.AddScoped<AuthorizedHandler>();
builder.Services.AddAuthorizationCore();

builder.Services.AddHttpClient(
    "default",
     (serviceProvider, client) =>
     {
         var navigationManager = serviceProvider.GetRequiredService<NavigationManager>();
         client.BaseAddress = new Uri(navigationManager.BaseUri);
     })
    .ConfigurePrimaryHttpMessageHandler(handler => new HttpClientHandler
    {
        // When a request is made to the backend and the response redirects to the login page,
        // the ajax call cannot redirect the user in a browser.
        // So, we avoid having this redirection, and the httpclient cancels the redirection instead of
        // trying to redirect and fails (Azure AD and Azure AD B2C do not support CORS)
        AllowAutoRedirect = false,
    })
    .AddHttpMessageHandler<AuthorizedHandler>();

builder.Services.AddTransient(sp => sp.GetRequiredService<IHttpClientFactory>().CreateClient("default"));

await builder.Build().RunAsync();
