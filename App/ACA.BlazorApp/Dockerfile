FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY ["ACA.BlazorApp/ACA.BlazorApp.csproj", "ACA.BlazorApp/"]
RUN dotnet restore "ACA.BlazorApp/ACA.BlazorApp.csproj"
COPY . .
WORKDIR "/src/ACA.BlazorApp"
RUN dotnet build "ACA.BlazorApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ACA.BlazorApp.csproj" -c Release -o /app/publish


FROM nginx:alpine AS final

EXPOSE 80
EXPOSE 443
WORKDIR /usr/share/nginx/html
COPY --from=publish /app/publish/wwwroot .
COPY ACA.BlazorApp/nginx.conf /etc/nginx/nginx.conf