------------------------
-- SERVER SIDE CONFIG --
------------------------

/*
-- create IAM group, assign users, create policy
-- In this example 'OracleIdentityCloudService' is the name of the IAM domain which may be different than yours

Allow group 'OracleIdentityCloudService'/'dba_users_group' to use database-family in tenancy
Allow group 'OracleIdentityCloudService'/'dba_users_group' to use database-connections in tenancy
*/ 

-- https://docs.oracle.com/en-us/iaas/exadatacloud/doc/connect-iam-users-to-oracle-exadata-database-service-on-dedicated-infra.html

-- connect to your database and execute the following
-- enable external auth
ALTER SYSTEM SET IDENTITY_PROVIDER_TYPE=OCI_IAM SCOPE=BOTH;

-- verify
SELECT NAME, VALUE FROM V$PARAMETER WHERE NAME='identity_provider_type';

-- create shared user and map to group
-- NOTE: If your domain is 'Default' then you do not need to specify the Domain in the mapping. e.g.
-- CREATE USER dba_user_schema IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=dba_users_group';
CREATE USER dba_user_schema IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=OracleIdentityCloudService/dba_users_group';

-- grant create session to user to allow login
GRANT CREATE SESSION TO dba_user_schema;

-- create role and map to group
-- NOTE: If your domain is 'Default' then you do not need to specify the Domain in the mapping. e.g.
-- CREATE ROLE dba_admin_role IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=dba_users_group';
CREATE ROLE dba_admin_role IDENTIFIED GLOBALLY AS 'IAM_GROUP_NAME=OracleIdentityCloudService/dba_admin_group';

-- Example escalation to allow the admins to view v$session table
GRANT SELECT ON v_$session TO dba_admin_role;

-- alternatively, create individual user
-- CREATE USER jjadmin IDENTIFIED GLOBALLY AS 'IAM_PRINCIPAL_NAME=OracleIdentityCloudService/john.admin@oracle.com';

/*
jdbc:oracle:thin:@(DESCRIPTION=(CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)
  (ADDRESS_LIST=
    (ADDRESS=(PROTOCOL=tcps)(HOST=xxx-xxxxx-scan.privateclientsu.exacsvcn.oraclevcn.com)(PORT=2484)))
  (CONNECT_DATA=(SERVICE_NAME=DBx_PDBx.paas.oracle.com))
(security=(ssl_server_dn_match=yes)))
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