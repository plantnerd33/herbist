# Dancer2 + MariaDB Web Application

This project is a containerized web application built with the Dancer2 Perl framework and MariaDB.

## Running the Application with OrbStack

1.  **Start OrbStack**: Ensure OrbStack is running on your machine.
2.  **Build and Start**: Run the following command in your terminal:
    ```bash
    docker-compose up --build
    ```
3.  **Access the App**: Open your browser to [http://localhost:8080](http://localhost:8080).

## Project Structure

- `bin/app.psgi`: Application entry point.
- `lib/MyApp.pm`: Main application logic and routes.
- `config.yml`: Application and database configuration.
- `views/`: Template files.
- `Dockerfile`: Container image definition.
- `docker-compose.yml`: Orchestration for the app and database.
- `cpanfile`: Perl dependencies.