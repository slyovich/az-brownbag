using ACA.BlazorApp.Providers;
using System.Net;

namespace ACA.BlazorApp.Handlers
{
    public class AuthorizedHandler : DelegatingHandler
    {
        private readonly IAuthenticationProvider _authenticationProvider;

        public AuthorizedHandler(IAuthenticationProvider authenticationProvider)
        {
            _authenticationProvider = authenticationProvider;
        }

        protected override async Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            var responseMessage = await base.SendAsync(request, cancellationToken);
            if (responseMessage.StatusCode == HttpStatusCode.Unauthorized)
            {
                // if server returned 401 Unauthorized, redirect to login page
                _authenticationProvider.SignIn();
            }

            return responseMessage;
        }
    }
}
