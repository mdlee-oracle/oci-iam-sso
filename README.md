# oci-iam-sso

- [IAM Authentication with Autonomous Database: Documentation](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/manage-users-iam.html)
- [IAM Authentication with Autonomous Database: Video Series](https://www.youtube.com/playlist?list=PLdtXkK5KBY5600tYKz2ZJFMGyqn6wWeK0)

# Using the OCI CLI for SSO DB Token Authentication

## Initial Setup - Create OCI Config File
For this guide, we want to use session tokens intead of API keys to ensure all access is ephemeral and nothing is stored permanently on the client. We are using the OCI CLI to grab the session and db_tokens used to authenticate to the database. Typically, the `oci setup config` command is used to create an intial OCI config. However, that process expects an API key - Which we won't have.

Instead, we will create a config file at `~/.oci/config` and populate it with the following information:
[Example Intial Configuration](example-config-initial)

Modify the lines (tenancy, region, security_token_file) with your own tenancy OCID, the region you are using, and the path where you would like your security token file to be stored.

## Retrieve the initial Session Token

We will utilize the OCI CLI `oci session authenticate` command to populate the initial session token file. On subsequent calls, we will use the `oci iam db-token get --auth security_token` command to refresh our session token (If expired) and grab our db_token.

1. Execute the following command to retrieve the inital session token. The token will be stored at the location specified by `security_token_file` in the OCI config. Optionally, connect to a specific region using the `--region` parameter

```
oci session authenticate [OPTIONAL --region us-langley-1]
```

2. Upon execution, a browser window will appear that will request your user's OCI IAM credentials. Enter your credentials. If successful, you will see the following message in the browser.

![Authorization completed](images/browser_authorization_complete.png)

3. Back in the shell where you executed the `oci session authenticate` command, you will be asked to `Enter the name of the profile you would like to create:`. Enter `DEFAULT` (case-sensitive) to save the information against your `DEFAULT` OCI Config profile.

4. You can verify the session token was successfully retrived by inspecting the file downloaded to the `security_token_file` path set in the OCI Config

## Retrieve the OCI IAM DB Token

Now that we have the session token, we can utilize it to authenticate and retrive our db token

1. Execute the following command to retrieve the db token

```
oci iam db-token get --auth security_token [OPTIONAL --region us-langley-1]
```

One benefit of using the `--auth security_token` option is that if your session token is expired, a prompt will appear stating:

```
ERROR: This CLI session has expired, so it cannot currently be used to run commands
Do you want to re-authenticate your CLI session profile? [Y/n]
```

Entering `Y` will enter the re-authentication process. Note that you must still run the `db-token get` command again once a new session token is retrieved to grab a db token.

2. Upon successful execution, the token will be stored by default at `~/.oci/db-token/token`

# Connecting to ADB-S using SQL*PLus and DB Token
This section will describe how to utilize OCI IAM session tokens to authenticate to an OCI hosted Autonomous Database (ADB-S) using Single Sign On (SSO).

## Architecture
<Insert Architecture here>

## Prerequisites
1. OCI CLI
1. SQL*Plus

## Configure connection using Wallet
We are using the ADB [wallet](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-download-wallet.html) to create a connection to our database. After downloading the wallet, copy the `sqlnet.ora` and `tnsnames.ora` file to your SQLPlus Instant Client directory at (ORACLE_HOME/network/admin)

The connection string needs to be modified to include the (TOKEN_AUTH=OCI_TOKEN) parameter:

```
xxxxxxxxxxxxxxxx_high = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-langley-1.oraclegovcloud.com))(connect_data=(service_name=gbded38435da8bd_xxxxxxxxxxxxxxxx_high.adb.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adb.us-langley-1.oraclegovcloud.com,O=Oracle Corporation,L=Redwood City,ST=California,C=US")(TOKEN_AUTH=OCI_TOKEN)))
```

## Connect using SQL*Plus

1. Using the OCI CLI, retrieve a db token using the steps shown above
1. Connect to the database using the service connection

```
sqlplus /@xxxxxxxxxxxxxxxx_high
```

# Connecting to ADB-S using SQLDeveloper and DB Token

## Prerequisites
1. OCI CLI
1. SQLDeveloper

## Configure connection using Wallet

We are using the ADB [wallet](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/connect-download-wallet.html) to create a connection to our database. Create a new connection in SQLDeveloepr and configure the service_name and wallet directory for your particular values.

![SQLDeveloper Configuration](images/sqldeveloper_db_token_configuration.png)

## Connect using SQLDeveloper

1. Using the OCI CLI, retrieve a db token using the steps shown above
1. Connect to the database by double clicking your connection