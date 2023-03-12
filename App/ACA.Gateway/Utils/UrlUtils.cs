﻿namespace ACA.Gateway.Utils
{
    public static class UrlUtils
    {
        public static string CombineUrls(string uri1, string uri2)
        {
            uri1 = uri1.TrimEnd('/');
            uri2 = uri2.TrimStart('/');
            return string.Format("{0}/{1}", uri1, uri2);
        }
    }
}
