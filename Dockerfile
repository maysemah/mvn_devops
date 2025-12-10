# Image de base avec Java 17
FROM openjdk:17-jdk-slim

# Définir le répertoire de travail
WORKDIR /app

# Copier le JAR de l'application
COPY target/*.jar app.jar

# Exposer le port 8080 (port par défaut de Spring Boot)
EXPOSE 8080

# Commande pour démarrer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]

