using Microsoft.AspNetCore.Components;

namespace ACA.BlazorApp.Providers
{
    public class AuthenticationProvider : IAuthenticationProvider
    {
        private const string _logInPath = "login";
        private const string _logOutPath = "logout";

        private readonly NavigationManager _navigation;

        public AuthenticationProvider(NavigationManager navigation)
        {
            _navigation = navigation;
        }

        public void SignIn(string? customReturnUrl = null)
        {
            var returnUrl = customReturnUrl != null ? _navigation.ToAbsoluteUri(customReturnUrl).ToString() : null;
            var encodedReturnUrl = Uri.EscapeDataString(returnUrl ?? _navigation.Uri);
            var logInUrl = _navigation.ToAbsoluteUri($"{_logInPath}?redirectUrl={encodedReturnUrl}");
            _navigation.NavigateTo(logInUrl.ToString(), true);
        }

        public void SignOut()
        {
            _navigation.NavigateTo(_navigation.ToAbsoluteUri(_logOutPath).ToString(), true);
        }
    }
}
