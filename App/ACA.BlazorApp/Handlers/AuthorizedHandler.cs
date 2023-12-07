using ACA.BlazorApp.Providers;
using Microsoft.AspNetCore.Components;
using System.Net;

namespace ACA.BlazorApp.Handlers
{
    public class AuthorizedHandler : DelegatingHandler
    {
        private readonly IAuthenticationProvider _authenticationProvider;
        private readonly NavigationManager _navigationManager;

        public AuthorizedHandler(
            IAuthenticationProvider authenticationProvider,
            NavigationManager navigationManager)
        {
            _authenticationProvider = authenticationProvider;
            _navigationManager = navigationManager;
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
            else if (responseMessage.StatusCode == 0)
            {
                // if we have a cancelled response, we refresh the page.
                // This may happen if the backend gives a redirect response, for instance when the user is not logged in
                _navigationManager.NavigateTo(_navigationManager.Uri, forceLoad: true);
            }

            return responseMessage;
        }
    }
}
