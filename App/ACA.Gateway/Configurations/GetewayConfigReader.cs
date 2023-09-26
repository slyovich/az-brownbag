namespace ACA.Gateway.Configurations
{
    public static class GetewayConfigReader
    {
        public static GatewayConfig GetGatewayConfig(this ConfigurationManager configuration)
        {
            return new GatewayConfig
            {
                SessionTimeoutInMin = configuration.GetValue("Gateway:SessionTimeoutInMin", 60),
                Version = configuration.GetValue("Gateway:Version", "1.0.0"),

                AuthorityType = configuration.GetValue<AuthorityType>("OpenIdConnect:AuthorityType"),
                Authority = configuration.GetValue<string>("OpenIdConnect:Authority"),
                ClientId = configuration.GetValue<string>("OpenIdConnect:ClientId"),
                ClientSecret = configuration.GetValue<string>("OpenIdConnect:ClientSecret"),
                Scopes = configuration.GetValue("OpenIdConnect:Scopes", ""),
                LogoutUrl = configuration.GetValue("OpenIdConnect:LogoutUrl", ""),
                QueryUserInfoEndpoint = configuration.GetValue("OpenIdConnect:QueryUserInfoEndpoint", true),

                ApiConfigs = configuration.GetSection("Apis").Get<ApiConfig[]>(),
            };
        }
    }
}
