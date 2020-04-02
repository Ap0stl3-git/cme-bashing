# cme-bashing
Bash script to automate common crackmapexec tasks

OPTIONS:

(1) Check all Domain Accounts in cmedb

  Runs against the SMB Database in cmedb.  Pulls all IP addresses in the database and then attempts to authenticate to each address via smb using all domain accounts in the database.  When complete, prints a list to screen and to file of all domain account / host   administrative privilege pairs.

  The goal of this script is to...
    1) Speed up the scans by only attempting to connect to IPs cme has seen active before.
    2) Identify ALL places ALL compromised domain accounts have administrative privileges, in an automated fashion.
      
      
(2) Check all Local-auth Accounts in cmedb

  Runs against the SMB Database in cmedb.  Pulls all IP addresses in the database and then attempts to authenticate to each address via smb using --local-auth accounts in the database.  It does this by pulling all accounts that do not match the "domain" name provided by the user.  When complete, prints a list to screen and to file of all --local-auth account / host   administrative privilege pairs.

  The goal of this script is to...
    1) Speed up the scans by only attempting to connect to IPs cme has seen active before.
    2) Identify ALL places ALL compromised --local-auth accounts have administrative privileges, in an automated fashion.
  
  
(3) Check all Domain and Local-auth Accounts (ALL)

   Combination of optins (1) & (2).
 
 
(4) Check single creds ID # (ONLY USE DOMAIN ACCOUNTS)
  Runs against the SMB Database in cmedb.  Pulls all IP addresses in the database and then attempts to authenticate to each address via smb using the specific account of the creds ID # provided by the user.  When complete, prints a list to screen and to file of all account / host administrative privilege pairs.

  The goal of this script is to...
    1) Speed up the scans by only attempting to connect to IPs cme has seen active before.
    2) Identify ALL places specified account has administrative privileges, in an automated fashion.
 
 
(5) Gather LSA Clear-text from all IPs using all Domain and Local-auth Accounts (LSA-ALL)

  Runs against the SMB Database in cmedb.  Pulls all IP addresses in the database and then attempts to authenticate and run the --lsa flag on each address via smb using ALL accounts in the database. Then filters/sorts the results to display on the screen and write to file all the "clear-text" creds found.  While it is running, you will see the actual results including the non-clear-text.  The cleaned results will be displayed once it completes.

  The goal of this script is to...
    1) Speed up the scans by only attempting to connect to IPs cme has seen active before.
    2) Run the --lsa flag and clear out all the hashes/noise to present only the "clear-text" creds.
  
  
(6) Gather DCC2 Hashes from all IPs using all Domain and Local-auth Accounts (DCC2-ALL)

  Runs against the SMB Database in cmedb.  Pulls all IP addresses in the database and then attempts to authenticate and run the --lsa flag on each address via smb using ALL accounts in the database. Then filters/sorts the results to display on the screen and write to file all the DCC2 domain cached credential hashes in the format needed to copy/paste into hashcat for cracking.  While it is running, you will see the actual results including the non-dcc2 creds.  The cleaned results will be displayed once it completes.

  The goal of this script is to...
    1) Speed up the scans by only attempting to connect to IPs cme has seen active before.
    2) Run the --lsa flag and clear out all the non-dcc2/noise to present only the dcc2 hashes in a format for cracking.
  
 (7) Display LSA Clear-text of All Previously Gathered
 
   Searches through the cme log files and pulls out all the "clear-text" creds that were discovered by the --lsa flag.  This option does not run a cme scan, but simply pulls data from the log files.
 
 
 (8) Display DCC2 Hashes of All Previously Gathered
 
  Searches through the cme log files from the --lsa flag, pulls out all the dcc2 hashes, and formats them for copy/paste into hashcat for cracking.  This option does not run a cme scan, but simply pulls data from the log files.
  
  
(9) Spider file contents for DA account IDs in provided txt file

  Runs the cme --spider option searching the "contents" of files for the names of accounts in the "Domain Admins" group.  Server and file share are provided by the user.  Path to a text file containin a list of domain admin accounts is also provided by the user.


(10) Spider filenames for common network configs

  Runs the cme --spider option searching filenames for common configuration files for network devices such as routers, switches, and firewalls.  Input file "network.txt" of keywords to search for can be modified by the user.


(11) Spider specific pattern for filename search

  This is just the standard cme --spider --pattern search.
