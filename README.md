# PersonalSpace

PersonalSpace is a Phoenix-based application designed for managing and tracking aircraft within the area of my personal ADB-S antenna at home. It utilizes CQRS and Event Sourcing patterns, leveraging the `commanded` library for domain modeling and event storage.

## Features

- **Aircraft Tracking**: Monitor aircraft movements in and out of defined airspace zones.
- **Event-Driven Architecture**: Uses CQRS (Command Query Responsibility Segregation) and Event Sourcing to maintain a robust and auditable history of aircraft operations.
- **Real-time Updates**: Changes are propagated via the Event Sourcing architecture, and projections in the DB reflect the changes in the event streams.
- **Telegram Integration**: Includes functionality for interacting with the system via Telegram. The Telegram bot can be reached out at @APersonalSpaceBot

## Technical Stack

- **Framework**: [Phoenix Framework](https://www.phoenixframework.org/)
- **Language**: [Elixir](https://elixir-lang.org/)
- **Event Sourcing/CQRS**: [Commanded](https://commanded.io/)
- **Database**: [PostgreSQL](https://www.postgresql.org/) with [Ecto](https://hexdocs.pm/ecto/Ecto.html) for my demo I used a Neon database.
- **Telegram API**: `telegram_ex`

## Getting Started

### Prerequisites

- Elixir (>= 1.15)
- PostgreSQL

### Installation

1. Clone the repository.
2. Install dependencies:
   ```bash
   mix deps.get
   ```
3. Set up the databases, for this the `.env` variables needed:

   ```bash


   DATABASE_URL=""

   DATABASE_URL_EVENTSTORE=""

   OPENSKY_CLIENT_ID=""
   OPENSKY_SECRET=""

   SERIAL=""

   TELEGRAM_TOKEN=""

   HOME_LAT=0.0
   HOME_LON=0.0
   ```

   One must also run all the migrations and `mix ecto.drop && mix ecto.create && mix ecto.migrate` as well as the migrations for the eventstore `mix event_store.drop && mix event_store.create && mix event_store.init`

4. Start the Phoenix server:
   ```bash
   mix phx.server
   ```
   Or inside an IEx session:
   ```bash
   iex -S mix phx.server
   ```

## Development

- **Run Tests**:
  ```bash
  mix test
  ```
- **Format Code**:
  ```bash
  mix format
  ```

## Configuration

This project requires configuration for database access and third-party integrations (e.g., Telegram, Neon database). Ensure all required environment variables are set in your local environment, but **do not commit these to source control**. Use a `.env` file for local development (which is included in `.gitignore`).
