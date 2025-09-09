------------------------
-- SERVER SIDE CONFIG --
------------------------

/*
-- create IAM group, assign users, create policy
-- In this example 'OracleIdentityCloudService' is the name of the IAM domain which may be different than yours

Allow group 'OracleIdentityCloudService'/'dba_users_group' to use database-connections in tenancy
*/ 

-- open sql developer web as admin and run below
-- https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/enable-iam-authentication.html
-- enable external auth
BEGIN
   DBMS_CLOUD_ADMIN.ENABLE_EXTERNAL_AUTHENTICATION( 
      type => 'OCI_IAM' );
END;
/

-- verify
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME='identity_provider_type';

-- create user and role mapped to group
CREATE USER dba_user_schema IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=OracleIdentityCloudService/dba_users_group';
CREATE ROLE dba_user_role IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=OracleIdentityCloudService/dba_users_group';

-- alternatively, create individual user
-- CREATE USER jsmith IDENTIFIED GLOBALLY AS 'IAM_PRINCIPAL_NAME=OracleIdentityCloudService/john.smith@oracle.com';

-- grant permissions to user and/or role
GRANT CREATE SESSION TO dba_user_role;
GRANT DWROLE TO dba_user_role; -- this role is specific to ADB

------------------------
-- CLIENT SIDE CONFIG --
------------------------

/*
-- set up and install oci cli

-- create session and token with browser login
oci session authenticate --region us-langley-1 
oci session authenticate --region us-chicago-1 

-- generate database token 
oci iam db-token get --auth security_token

-- refresh session if needed 
oci session refresh 

-- download wallet from console
-- set up custom jdbc connection in sql developer:
-- add and verify MY_WALLET_DIRECTORY 
-- add TOKEN_AUTH

jdbc:oracle:thin:@(description= (retry_count=20)(retry_delay=3)
(address=(protocol=tcps)(port=1522)
(host=adb.us-langley-1.oraclegovcloud.com))
(connect_data=(service_name=gbded38435da8bd_xxxxxxxxxxxxxxxx_high.adb.oraclecloud.com))
(security=(ssl_server_dn_match=yes)
# MAC (MY_WALLET_DIRECTORY=/Users/MyUser/Desktop/Wallet_xxxxxxxxxxxxxxxx/)
# WINDOWS (MY_WALLET_DIRECTORY=C:\Users\opc\Desktop\wallet)
(TOKEN_AUTH=OCI_TOKEN)))

-- sql developer will now pick up token from default location and allow login 
*/ 

------------------------
-- VERIFY TOKEN LOGIN --
------------------------

-- check connection status
SELECT SYS_CONTEXT('USERENV','AUTHENTICATION_METHOD') FROM DUAL;

-- CURRENT_USER will show the schema you are mapped to
SELECT SYS_CONTEXT('USERENV','CURRENT_USER') FROM DUAL;
SELECT SYS_CONTEXT('USERENV','IDENTIFICATION_TYPE') FROM DUAL;

-- AUTHENTICATED_IDENTITY will be your IAM username
SELECT SYS_CONTEXT('USERENV','AUTHENTICATED_IDENTITY') FROM DUAL;

-- ENTERPRISE_IDENTITY will be your IAM user OCID
SELECT SYS_CONTEXT('USERENV','ENTERPRISE_IDENTITY') FROM DUAL;