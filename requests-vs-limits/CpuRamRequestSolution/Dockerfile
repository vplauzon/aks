#	Multi-stage docker build file (see https://docs.docker.com/develop/develop-images/multistage-build/)
#	Use a Microsoft image with .NET core runtime (https://hub.docker.com/_/microsoft-dotnet-core-sdk/)
FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build

WORKDIR /src

#	Copy source code into the source folder
COPY . .

#	Publish the app into the app folder
RUN dotnet publish CpuRamRequestApi -c release -o app

###########################################################
#	Final container image
#	Use a Microsoft image with .NET core runtime (https://hub.docker.com/_/microsoft-dotnet-core-aspnet)
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2 AS final

#	Set the working directory to /work
WORKDIR /work

#	Copy package
COPY --from=build /src/CpuRamRequestApi/app .

# Make port 80 available to the world outside this container

EXPOSE 80

#	Define environment variables
ENV TODO ""

#	Run console app
CMD ["dotnet", "CpuRamRequestApi.dll"]