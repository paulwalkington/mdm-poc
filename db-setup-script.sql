CREATE SCHEMA extensions;
GRANT USAGE ON SCHEMA extensions TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA extensions GRANT EXECUTE ON FUNCTIONS TO PUBLIC;
ALTER DATABASE dev_postgres SET SEARCH_PATH TO "$user",public,extensions;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"     with schema extensions;
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch" with schema extensions;

-- Create the repository user and schema
CREATE USER semarchy_repository WITH PASSWORD 'semarchy_repository';
GRANT semarchy_repository TO dev_postgres_user;
CREATE SCHEMA semarchy_repository AUTHORIZATION semarchy_repository;

-- Create the repository read-only user
CREATE USER semarchy_repository_ro WITH PASSWORD 'semarchy_repository_ro';

GRANT CONNECT ON DATABASE dev_postgres to semarchy_repository_ro;

-- Set the search path to include the repository
ALTER ROLE semarchy_repository_ro SET SEARCH_PATH TO "$user", semarchy_repository,public,extensions;

-- Run the following commands after the repository creation
-- Grant select privileges on the profiling tables
GRANT USAGE ON SCHEMA semarchy_repository TO semarchy_repository_ro;

CREATE USER devdloc WITH PASSWORD 'devdloc';
GRANT devdloc TO dev_postgres_user;

CREATE SCHEMA devdloc AUTHORIZATION devdloc;

-- Grant data-loading privileges to the data location owner
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA semarchy_repository TO devdloc;


-- extra stuff which i've added, may not be needed
GRANT ALL PRIVILEGES ON SCHEMA public TO semarchy_repository;
GRANT ALL PRIVILEGES ON SCHEMA public TO semarchy_repository_ro;
