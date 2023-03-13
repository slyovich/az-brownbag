using Microsoft.AspNetCore.Authentication.OpenIdConnect;

namespace ACA.Gateway.Handlers
{
    public interface ITokenHandler
    {
        void HandleToken(TokenValidatedContext context);
    }
}