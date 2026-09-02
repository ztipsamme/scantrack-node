# Din Dockerfile — fyll i de saknade raderna
# Använd multi-stage build precis som på lektionen

# Stage 1: Bygg
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# TODO: Kopiera projektfilen och kör restore
COPY ScanTrackNode/*.csproj ./ScanTrackNode/
RUN dotnet restore ./ScanTrackNode/ScanTrackNode.csproj

# TODO: Kopiera resten av koden och publicera
COPY ScanTrackNode/. ./ScanTrackNode/
COPY data/cities.csv ./data/cities.csv
RUN dotnet publish ./ScanTrackNode/ScanTrackNode.csproj -c Release -o /app/publish

# TODO: Kopiera CSV-filen (den behövs i runtime-imagen också)


# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# TODO: Kopiera det publicerade projektet från build-steget
COPY --from=build /app/publish .


# Porten appen lyssnar på inuti containern
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# TODO: Starta appen
ENTRYPOINT ["dotnet", "ScanTrackNode.dll"]
