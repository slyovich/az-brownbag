﻿namespace ACA.Gateway.Models
{
    public class TokenExchangeResponse
    {
        public string access_token { get; set; } = "";
        public string refresh_token { get; set; } = "";
        public long expires_in { get; set; }
    }
}
