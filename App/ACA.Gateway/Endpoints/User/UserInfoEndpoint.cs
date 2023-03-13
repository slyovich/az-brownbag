using System.Security.Claims;

namespace ACA.Gateway.Endpoints.User
{
    public static class UserInfoEndpoint
    {
        public static void UserInfoRoute(this IEndpointRouteBuilder app)
        {
            app
                .MapGet("/userinfo", UserInfo)
                .RequireAuthorization();
        }

        private static IResult UserInfo(ClaimsPrincipal user)
        {
            var claims = user.Claims;
            var dict = new Dictionary<string, string>();

            foreach (var entry in claims)
            {
                dict[entry.Type] = entry.Value;
            }

            return Results.Ok(dict);
        }
    }
}
