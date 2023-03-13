namespace ACA.BlazorApp.Providers
{
    public interface IAuthenticationProvider
    {
        void SignIn(string? customReturnUrl = null);
        void SignOut();
    }
}